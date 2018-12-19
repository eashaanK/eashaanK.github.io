open Types
open State


  (*Time-step*)
  let delta = 2.2
  (*Constant in front of the MTCS value function*)
  let c = sqrt 2.0
  (*Number of times to run the algorithm*)
  let easy_iterations = 50
  let medium_iterations = 125
  let hard_iterations = 200

  let max_random_iters = ref 100

  (* fraction of wins, number of times played, daughter nodes,
   * commands that got here, possible commands from here*)

  (*Node (state, command from parent, win_pctg, times_played,
  daughter_nodes, parent_node, is_max_state)*)
  type tree =
    | Leaf of command * float
    | Node of Types.state * command * float * float * ((tree ref) array) *
              tree ref * bool

(**
 * [to_allegiance] is the allegiance value associated with
      a max or min node
   [max_bool] - if it's a max node then true else false
 *)
  let to_allegiance max_bool =
    if max_bool then Enemy else Player

(**
 * [get_random_command] returns a completely random legal
      move for the team with a given allegiance
   [st] - the state from which to get legal moves
   [allegiance] - the team that's going to move
 *)
  let get_random_command st allegiance =
    let commands = possible_commands st allegiance in
    let range = Array.length commands in
    let index = Random.int range in
    Array.get commands index

(**
 * [random_playout] is a the result of a random game
      starting from [st] with the first move being a
      max move if [max_bool] is true, else it's a
      min move
   [st'] - the starting state
   [max_bool'] - whether or not the first move is a max node
 *)
  let random_playout st' max_bool' =
    let rec rand_w_iters st max_bool iters =
      if iters > !max_random_iters then 0.4 +. (Random.float 0.2) else
      if State.gameover st then
        if st.player_score > st.enemy_score then
          0.0 +. 0.3 *. (float_of_int iters) /. (float_of_int !max_random_iters)
        else
          1.0 -. 0.3 *. (float_of_int iters) /. (float_of_int !max_random_iters)
      else
        if max_bool then
          let cm = get_random_command st Enemy in
          let new_state = new_state_plus_delta st cm delta in
          rand_w_iters new_state false (iters + 1)
        else
          let cm = get_random_command st Player in
          let new_state = new_state_plus_delta st cm delta in
          rand_w_iters new_state true (iters+1) in
    rand_w_iters st' max_bool' 0

(**
 * [get_times_sampled] is a getter function that returns the
      number of times sub-tree [t] has been played out
   [t] - the sub-tree in question
 *)
  let get_times_sampled t =
    match t with
    | Node(st,cm,v,n,children,parent,_) -> n
    | Leaf _ -> 1.0 (*so that log doesn't blow up*)

(**
 * [get_value] is the value of the tree [t] used for determining
      which node to be selected next
   [t] - the sub-tree in question
   [is_max] - whether or not the root of [t] is a max node
 *)
  let get_value t is_max =
    match t with
    | Leaf (_,v)-> 10000.0
    | Node(st,cm,v,n,children,parent,_) -> begin
        if is_max then
          v +. c *. sqrt (log (get_times_sampled !parent))/.n
        else
          (1.0-.v) +. c *.sqrt (log (get_times_sampled !parent))/.n
      end

(**
 * [create_children] is an array of Leaf values, one for each
      possible command starting from a given state
   [st] - the state from which to get the possible commands
   [allegiance] - the team whose turn it is
 *)
  let create_children st allegiance =
    let moves = possible_commands st allegiance in
    Array.map (fun cm -> ref (Leaf (cm,10000.0))) moves

(**
 * [get_extreme_child] is the next node to be chosen based on
      the value of the nodes
   [node] - the node whose children nodes are chosen from
   [is_max] - whether node is a max node
 *)
  let get_extreme_child node is_max =
    let func = (>) in (*if is_max then (>) else (>) in*)
    let children =
      match !node with
      | Node(_,_,_,_,chldrn,_,is_max_bool) -> chldrn
      | Leaf _ -> [||] in
    Array.fold_left
      (fun acc child -> if (func (get_value !child is_max) (get_value !acc is_max)) then child else acc)
      (Array.get children 0) children

(**
 * [update_node] updates the value of [node] depending on the
      results of a random playout [win_loss]
   [node] - the node to update
   [win_loss] - the win-value of the random playout (loss:0,win:1)
 *)
  let update_node node win_loss =
    match !node with
    | Node(st,cm,v,n,children,parent,is_max) -> begin
        node := Node(st,cm,v +. (win_loss-.v)/.(n+.1.0),n+.1.0,children,parent,is_max);
      end
    | Leaf _ -> ()

(**
 * [update_tree] recursively updates the current node [node] and
      all parent nodes with a random playout result
   [node] - the bottom node to be updated
   [win_loss] - the win-value of the random playout (loss:0,win:1)
 *)
  let rec update_tree node win_loss =
    match !node with
    | Node(st,cm,v,n,children,parent,is_max) -> begin
        update_node node win_loss;
        update_tree parent win_loss
      end
    | Leaf _ -> ()

(**
 * [new_node] is a new node created after selecting a command
      [cm] from the best available node.
   [node] - the parent node for the new node
   [cm] - the command to go from the old state in [node] to
      the new state in [new_node]
 *)
  let new_node node cm =
    match !node with
    | Node(old_st,old_cm,v,n,children,parent,is_max) ->
      let new_st = new_state_plus_delta old_st cm delta in
      let rand_play = random_playout new_st is_max in
      update_tree node rand_play;
      ref (Node(new_st, cm, rand_play, 0.0,
                create_children old_st (to_allegiance (not is_max)), node, not is_max))
    | Leaf _ -> node

(**
 * [beginning_node] is the root node of the entire tree
   [st] - the beginning state of the tree
 *)
  let beginning_node st =
    let children = create_children st Enemy in
    ref (Node(st,Null,0.0,0.0,children,ref (Leaf(Null,1.)),true))

(**
 * [add_path] creates a new random playout, creates a new node
      and updates all relevant nodes.
   [t] - the root node of the tree to add a playout to
 *)
  let rec add_path t =
    begin
      match !t with
      | Node(st,cm,v,n,children,parent,is_max) -> begin
          let ex_child = get_extreme_child t is_max in
          match !ex_child with
          | Node _ -> add_path ex_child
          | Leaf (cm,_) -> ex_child := !(new_node t cm)
        end
      | Leaf _ -> ()
    end

(**
 * [create_tree] instantiates a new tree starting with state and
      runs [iters] number of [add_path] commands to it to form the tree
   [st] - the starting state of the tree
   [iters] - the number of times to [add_path]
 *)
  let create_tree st iters =
    let root = beginning_node st in
    let counter = ref 0 in
    while !counter < iters do
      add_path root;
      counter := !counter + 1
    done;
    root

(**
 * [win_pctg] gets the win percentage for the give node
   [node] - the aformentioned node
 *)
  let win_pctg node =
    match !node with
    | Node(st,cm,v,n,children,parent,is_max) -> v
    | Leaf _ -> 0.0

(**
 * [get_highest_percentage] is the child node with the highest
      win percentage
   [node] - the parent node whose best child node will be returned
 *)
  let get_highest_percentage node =
    (*The line below is strictly to settle ties in a random way. The added
      values are small enough to be within the margin of error and will not
      make the algorithm choose a clearly worse move*)
    let func a b = (a +. (Random.float 0.00001) > b +. (Random.float 0.00001)) in
    let children =
      match !node with
      | Node(_,_,_,_,chldrn,_,_) -> chldrn
      | Leaf _ -> [||] in
    (*print_endline ("Children length: "^(string_of_int (Array.length children)));*)
    Array.fold_left
      (fun acc child -> if (func (win_pctg child) (win_pctg acc)) then child else acc)
      (Array.get children 0) children

  let move_to_string cm =
    match cm with
    | Move (team,s,e) -> let team_str =
      match team with
        | Enemy -> "Enemy"
        | Player -> "Player"
        | Neutral -> "Neutral" in
      team_str ^ " " ^ (string_of_int s) ^ " " ^ (string_of_int e)
    | _ -> "Null/skill"

  let get_cm t =
    match !t with
    | Node(st,cm,v,n,children,parent,is_max) -> cm
    | Leaf (cm,v) -> cm

  let to_string t =
    let str = "" in
    let to_str_node n=
      match n with
      | Node(st,cm,v,n,children,parent,is_max) ->
        (move_to_string cm)^ "; " ^ "Value: " ^ (string_of_float v) ^
        "; " ^ "Is max? " ^ (string_of_bool is_max) ^ "\n"
      | Leaf _ -> "Leaf\n" in
    let str = str ^ to_str_node t in
    let chldrn =
      match t with
      | Node(st,cm,v,n,children,parent,is_max) -> children
      | Leaf _ -> [||] in
    let str = str ^ (Array.fold_left (fun acc e -> acc^(move_to_string (get_cm e))^"; ") "" chldrn) ^ "\n\n" in
    let str = str ^ (Array.fold_left (fun acc e -> acc^(to_str_node !e)) "" chldrn) in
    str

  let get_move st difficulty =
    let t =
      match difficulty with
      | Easy -> create_tree st easy_iterations
      | Medium -> create_tree st medium_iterations
      | Hard -> create_tree st hard_iterations in
    (* print_endline (to_string !t); *)
    let child = get_highest_percentage t in
    match !child with
    | Node(_,cm,_,_,_,_,_) -> cm
    | Leaf(cm,_) -> cm
