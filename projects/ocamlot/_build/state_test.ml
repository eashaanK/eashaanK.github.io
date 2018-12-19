open Types
open OCamlotUnit2
open State

(* initial player movement of 5 troops with 100. speed and no progress
   going from tower 1 to tower 2.
*)
let init_movement02 : movement = {
  start_tower = 0;
  end_tower = 2;
  mvmt_troops = 5;
  mvmt_sprite = Sprite.blue_troop1_right;
  mvmt_team = Player;
  progress = 0.;
  damage = 1.;
  speed = 100.;
}

let init_troop_regen_speed = 1.

let base_init_troop_count = 10.

let base_max = 100.

let mini_max = 30.

let troop_foot_soldier = {
  trp_type = Foot;
  trp_damage = 1.;
  trp_speed = 100.;
}

let troop_cavalry = {
  trp_type = Cavalry;
  trp_damage = 2.;
  trp_speed = 200.;
}

let base_player_tower = {
  twr_id = 0;
  twr_pos = {x = 0.; y = 50.};
  twr_size = {w = 72.; h = 136.};
  twr_sprite = Sprite.tower_base;
  twr_troop_info = troop_foot_soldier;
  twr_troops = base_init_troop_count;
  twr_troops_max = base_max;
  twr_troops_regen_speed = init_troop_regen_speed;
  twr_team = Player;
  selector_offset = {x = 0.; y = 100.};
  count_label_offset = {x = 10.; y = 5.};
  is_disabled = false
}

(* A copy used for immutability tests to compare against original *)
let base_player_tower_copy = {
  twr_id = 0;
  twr_pos = {x = 0.; y = 50.};
  twr_size = {w = 72.; h = 136.};
  twr_sprite = Sprite.tower_base;
  twr_troop_info = troop_foot_soldier;
  twr_troops = base_init_troop_count;
  twr_troops_max = base_max;
  twr_troops_regen_speed = init_troop_regen_speed;
  twr_team = Player;
  selector_offset = {x = 0.; y = 100.};
  count_label_offset = {x = 10.; y = 5.};
  is_disabled = false
}

let neutral_mini_cavalry = {
  twr_id = 1;
  twr_pos = {x = 300.; y = 200.};
  twr_size = {w = 56.; h = 56.};
  twr_sprite = Sprite.tower_type1;
  twr_troop_info = troop_cavalry;
  twr_troops = 0.;
  twr_troops_max = mini_max;
  twr_troops_regen_speed = init_troop_regen_speed;
  twr_team = Neutral;
  selector_offset = {x = 0.; y = 40.};
  count_label_offset = {x = 0.; y = (-1.) *. 10.};
  is_disabled = false
}

(* A copy used for immutability tests *)
let neutral_mini_cavalry_copy = {
  twr_id = 1;
  twr_pos = {x = 300.; y = 200.};
  twr_size = {w = 56.; h = 56.};
  twr_sprite = Sprite.tower_type1;
  twr_troop_info = troop_cavalry;
  twr_troops = 0.;
  twr_troops_max = mini_max;
  twr_troops_regen_speed = init_troop_regen_speed;
  twr_team = Neutral;
  selector_offset = {x = 0.; y = 40.};
  count_label_offset = {x = 0.; y = (-1.) *. 10.};
  is_disabled = false
}

let base_enemy_tower = {
  twr_id = 2;
  twr_pos = {x = Renderer.width -.72.; y = Renderer.height -. 136.};
  twr_size = {w = 72.; h = 136.};
  twr_sprite = Sprite.tower_base;
  twr_troop_info = troop_foot_soldier;
  twr_troops = base_init_troop_count;
  twr_troops_max = base_max;
  twr_troops_regen_speed = init_troop_regen_speed;
  twr_team = Enemy;
  selector_offset = {x = 0.; y = 100.};
  count_label_offset = {x = 0.; y = (-1.) *. 10.};
  is_disabled = false
}

(* A copy used for immutability tests to compare against original *)
let base_enemy_tower_copy = {
  twr_id = 2;
  twr_pos = {x = Renderer.width -.72.; y = Renderer.height -. 136.};
  twr_size = {w = 72.; h = 136.};
  twr_sprite = Sprite.tower_base;
  twr_troop_info = troop_foot_soldier;
  twr_troops = base_init_troop_count;
  twr_troops_max = base_max;
  twr_troops_regen_speed = init_troop_regen_speed;
  twr_team = Enemy;
  selector_offset = {x = 0.; y = 100.};
  count_label_offset = {x = 0.; y = (-1.) *. 10.};
  is_disabled = false
}

let init_state : state = {
  towers = [|base_player_tower; neutral_mini_cavalry; base_enemy_tower|];
  num_towers = 3;
  player_score = 1;
  enemy_score = 1;
  movements = [];
  player_skill = None;
  enemy_skill = None;
  player_mana = 250.;
  enemy_mana = 250.;
}

(* A copy used for immutability tests *)
let init_state_copy : state = {
  towers = [|base_player_tower_copy; neutral_mini_cavalry_copy;
             base_enemy_tower_copy|];
  num_towers = 3;
  player_score = 1;
  enemy_score = 1;
  movements = [];
  player_skill = None;
  enemy_skill = None;
  player_mana = 250.;
  enemy_mana = 250.;
}

let init_stun_from_player_valid = {
  allegiance = Player;
  mana_cost = 100;
  effect = Stun 5.;
  regen_timer = {curr_time = 0.; speed = 1.; limit = 7.};
  tower_id = 2;
  sprite = Sprite.sprite_freeze;
  anim_timer = {curr_time = 0.; speed = 1.; limit = 0.};
}

let init_stun_from_enemy_valid = {
  allegiance = Enemy;
  mana_cost = 100;
  effect = Stun 5.;
  regen_timer = {curr_time = 0.; speed = 1.; limit = 0.};
  tower_id = 0;
  sprite = Sprite.sprite_freeze;
  anim_timer = {curr_time = 0.; speed = 1.; limit = 0.};
}

let init_kill_from_player_valid = {
  allegiance = Player;
  mana_cost = 70;
  effect = Kill 15;
  regen_timer = {curr_time = 0.; speed = 1.; limit = 0.};
  tower_id = 2;
  sprite = Sprite.sprite_freeze;
  anim_timer = {curr_time = 0.; speed = 1.; limit = 0.}
}

let init_kill_from_enemy_valid = {
  allegiance = Enemy;
  mana_cost = 70;
  effect = Kill 15;
  regen_timer = {curr_time = 0.; speed = 1.; limit = 0.};
  tower_id = 0;
  sprite = Sprite.sprite_freeze;
  anim_timer = {curr_time = 0.; speed = 1.; limit = 0.}
}

let init_reg_from_player_valid1 = {
  allegiance = Player;
  mana_cost = 0;
  effect = Regen_incr 5.;
  regen_timer = {curr_time = 0.; speed = 1.; limit = 0.};
  tower_id = 0;
  sprite = Sprite.sprite_freeze;
  anim_timer = {curr_time = 0.; speed = 1.; limit = 0.};
}

let init_reg_from_enemy_valid1 = {
  allegiance = Enemy;
  mana_cost = 0;
  effect = Regen_incr 5.;
  regen_timer = {curr_time = 0.; speed = 1.; limit = 0.};
  tower_id = 2;
  sprite = Sprite.sprite_freeze;
  anim_timer = {curr_time = 0.; speed = 1.; limit = 0.};
}

let init_reg_from_player_valid2 = {
  allegiance = Player;
  mana_cost = 0;
  effect = Regen_incr 0.2;
  regen_timer = {curr_time = 0.; speed = 1.; limit = 0.};
  tower_id = 2;
  sprite = Sprite.sprite_freeze;
  anim_timer = {curr_time = 0.; speed = 1.; limit = 0.};
}

let init_reg_from_enemy_valid2 = {
  allegiance = Enemy;
  mana_cost = 0;
  effect = Regen_incr 0.2;
  regen_timer = {curr_time = 0.; speed = 1.; limit = 0.};
  tower_id = 0;
  sprite = Sprite.sprite_freeze;
  anim_timer = {curr_time = 0.; speed = 1.; limit = 0.};
}

(* A fake, ridiculously high time delta to produce test cases *)
let delta = 0.1

(* tower without [twr_sprite], [selector_offset], or [count_label_offset] *)
type tower_core = {
  twr_id : int;
  twr_pos : vector2d;
  twr_size : bounds;
  twr_troop_info : troop;
  twr_troops : float;
  twr_troops_max : float;
  twr_troops_regen_speed : float;
  twr_team : allegiance;
  is_disabled : bool;
}

(* a movement without [mvmt_sprite] *)
type movement_core = {
  start_tower : int;
  end_tower : int;
  mvmt_troops : int;
  mvmt_team : allegiance;
  progress : float;
  damage : float;
  speed : float;
}

(* a skill without [sprite] *)
type skill_core = {
  allegiance : allegiance;
  mana_cost : int;
  effect : effect;
  regen_timer : timer;
  tower_id : int;
  anim_timer : timer;
}

(* Represents the state without any information about sprites or other visual
   elements better verifiable by playtesting.
*)
type state_core = {
  towers : tower_core array;
  num_towers : int;
  player_score : int;
  enemy_score : int;
  movements : movement_core list;
  player_skill : skill_core option;
  enemy_skill : skill_core option;
  player_mana : float;
  enemy_mana : float;
}

(* Converts a tower array to a tower_core_array *)
let tower_to_core (towers : tower array) : tower_core array =
  Array.map (fun t ->
      ignore (t.twr_sprite); (* OCaml doesn't know [towers] is a [tower array]
                                unless you use something only a [tower] has. *)
      {
        twr_id = t.twr_id;
        twr_pos = t.twr_pos;
        twr_size = t.twr_size;
        twr_troop_info = t.twr_troop_info;
        twr_troops = t.twr_troops;
        twr_troops_max = t.twr_troops_max;
        twr_troops_regen_speed = t.twr_troops_regen_speed;
        twr_team = t.twr_team;
        is_disabled = t.is_disabled
      }
    ) towers

(* Produces a skill_core option out of a skill option *)
let skill_to_core (skill : skill option) : skill_core option =
  match skill with
  | None -> None
  | Some sk -> Some
    begin
      {
        allegiance = sk.allegiance;
        mana_cost = sk.mana_cost;
        effect = sk.effect;
        regen_timer = sk.regen_timer;
        tower_id = sk.tower_id;
        anim_timer = sk.anim_timer;
      }
    end

(* Converts a list of movements to a list of [movement_core]s. *)
let movements_to_core (movements : movement list) : movement_core list =
  List.map (fun m -> ignore (m.mvmt_sprite); (* Needed for type checking *)
      {
        start_tower = m.start_tower;
        end_tower = m.end_tower;
        mvmt_troops = m.mvmt_troops;
        mvmt_team = m.mvmt_team;
        progress = m.progress;
        damage = m.damage;
        speed = m.speed;
      }
    ) movements

(* Converts a [state] to a [state_core] *)
let state_to_core (st : state) : state_core =
  let towers_core = tower_to_core st.towers in
  let player_skill_core = skill_to_core st.player_skill in
  let enemy_skill_core = skill_to_core st.enemy_skill in
  let movements_core = movements_to_core st.movements in
  {
    towers = towers_core;
    num_towers = st.num_towers;
    player_score = st.player_score;
    enemy_score = st.enemy_score;
    movements = movements_core;
    player_skill = player_skill_core;
    enemy_skill = enemy_skill_core;
    player_mana = st.player_mana;
    enemy_mana = st.enemy_mana;
  }

(* Creates a [tower] array out of a [tower_core] array by using dummy values
   for fields of [tower] not in [tower_core].
*)
let core_to_towers (towers : tower_core array) : tower array =
  Array.map (fun tc ->
      {
        twr_id = tc.twr_id;
        twr_pos = tc.twr_pos;
        twr_size = tc.twr_size;
        twr_sprite = Sprite.tower_type1; (* Dummy sprite *)
        twr_troop_info = tc.twr_troop_info;
        twr_troops = tc.twr_troops;
        twr_troops_max = tc.twr_troops_max;
        twr_troops_regen_speed = tc.twr_troops_regen_speed;
        twr_team = tc.twr_team;
        selector_offset = {x=0.;y=50.}; (* Dummy offset *)
        count_label_offset = {x = 10.; y = 5.}; (* Dummy offset *)
        is_disabled = tc.is_disabled;
      }
    ) towers

(* Creates a [skill] option out of a [skill_core] option by using dummy values
   for fields of [skill] not in [skill_core].
*)
let core_to_skill (skill_core : skill_core option) : skill option =
  match skill_core with
  | None -> None
  | Some skc -> Some (
    {
      allegiance = skc.allegiance;
      mana_cost = skc.mana_cost;
      effect = skc.effect;
      regen_timer = skc.regen_timer;
      tower_id = skc.tower_id;
      sprite = Sprite.sprite_freeze; (* Dummy sprite *)
      anim_timer = skc.anim_timer;
    }
  )

(* Creates a [movement] list out of a [movement_core] list by using
   dummy values for fields of [movement] not in [movement_core].
*)
let core_to_movements (mvmts_core : movement_core list) : movement list =
  List.map (fun mc ->
      {
        start_tower = mc.start_tower;
        end_tower = mc.end_tower;
        mvmt_troops = mc.mvmt_troops;
        mvmt_sprite = Sprite.blue_troop1_right;
        mvmt_team = mc.mvmt_team;
        progress = mc.progress;
        damage = mc.damage;
        speed = mc.speed;
      }
    ) mvmts_core

(* Creates a [state] out of a [state_core] by using dummy values for
   everything that a [state] contains that a [state_core] does not contain.
*)
let core_to_state (stc : state_core) : state =
  let player_skill = core_to_skill stc.player_skill in
  let enemy_skill = core_to_skill stc.enemy_skill in
  let movements = core_to_movements stc.movements in
  let towers = core_to_towers stc.towers in
  {
    towers = towers;
    num_towers = stc.num_towers;
    player_score = stc.player_score;
    enemy_score = stc.enemy_score;
    movements = movements;
    player_skill = player_skill;
    enemy_skill = enemy_skill;
    player_mana = stc.player_mana;
    enemy_mana = stc.enemy_mana;
  }

let (~>>) = core_to_state

let (~<<) = state_to_core

let helper_tests = [
  "new_mvmt" >:: (fun _ -> assert_equal init_movement02
                     (new_movement 0 2 5 Sprite.blue_troop1_right Player 1. 100.));
]

let state_immutability_tests : test list = [
  (* This section of state tests will assert the immutability of a previous
     state after creating a new one from that previous state. *)
  "immtbl_axiom" >:: (fun _ -> assert_equal init_state init_state_copy);
  "pssbl_immtbl1" >:: (fun _ -> assert_equal init_state
          (ignore (possible_commands init_state_copy Player); init_state_copy));
  "pssbl_immtbl2" >:: (fun _ -> assert_equal init_state
          (ignore (possible_commands init_state_copy Enemy); init_state_copy));
  "nst_immtbl1" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy (Move (Player, 0, 1)));
                         init_state_copy));
  "nst_immtbl2" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy (Move (Player, 0, 2)));
                         init_state_copy));
  "nst_immtbl3" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy (Move (Enemy, 2, 1)));
                         init_state_copy));
  "nst_immtbl4" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy (Move (Enemy, 2, 0)));
                         init_state_copy));
  "nst_immtbl5" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy
                                   (Skill init_stun_from_player_valid));
                         init_state_copy));
  "nst_immtbl9" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy
                                   (Skill init_stun_from_enemy_valid));
                         init_state_copy));
  "nst_immtbl6" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy
                                   (Skill init_kill_from_player_valid));
                         init_state_copy));
  "nst_immtbl10" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy
                                   (Skill init_kill_from_enemy_valid));
                         init_state_copy));
  "nst_immtbl7" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy
                                   (Skill init_reg_from_player_valid1));
                         init_state_copy));
  "nst_immtbl11" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy
                                   (Skill init_reg_from_enemy_valid1));
                         init_state_copy));
  "nst_immtbl8" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy
                                   (Skill init_reg_from_player_valid2));
                         init_state_copy));
  "nst_immtbl12" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state init_state_copy
                                   (Skill init_reg_from_enemy_valid2));
                         init_state_copy));
  "nspd_immtbl1" >:: (fun _ -> assert_equal init_state
                         (ignore (new_state_plus_delta init_state_copy
                                    (Move (Player, 0, 1)) delta);
                          init_state_copy));
  "nspd_immtbl2" >:: (fun _ -> assert_equal init_state
                         (ignore (new_state_plus_delta init_state_copy
                                    (Move (Player, 0, 2)) delta);
                          init_state_copy));
  "nspd_immtbl3" >:: (fun _ -> assert_equal init_state
                         (ignore (new_state_plus_delta init_state_copy
                                    (Move (Enemy, 2, 1)) delta);
                          init_state_copy));
  "nspd_immtbl4" >:: (fun _ -> assert_equal init_state
                         (ignore (new_state_plus_delta init_state_copy
                                    (Move (Enemy, 2, 0)) delta);
                          init_state_copy));
  "nspd_immtbl5" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state_plus_delta init_state_copy
                                   (Skill init_stun_from_player_valid) delta);
                         init_state_copy));
  "nspd_immtbl6" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state_plus_delta init_state_copy
                                   (Skill init_kill_from_player_valid) delta);
                         init_state_copy));
  "nspd_immtbl7" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state_plus_delta init_state_copy
                                   (Skill init_reg_from_player_valid1) delta);
                         init_state_copy));
  "nspd_immtbl8" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state_plus_delta init_state_copy
                                   (Skill init_reg_from_player_valid2) delta);
                         init_state_copy));
  "nspd_immtbl9" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state_plus_delta init_state_copy
                                   (Skill init_stun_from_enemy_valid) delta);
                         init_state_copy));
  "nspd_immtbl10" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state_plus_delta init_state_copy
                                   (Skill init_kill_from_enemy_valid) delta);
                         init_state_copy));
  "nspd_immtbl11" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state_plus_delta init_state_copy
                                   (Skill init_reg_from_enemy_valid1) delta);
                         init_state_copy));
  "nspd_immtbl12" >:: (fun _ -> assert_equal init_state
                        (ignore (new_state_plus_delta init_state_copy
                                   (Skill init_reg_from_enemy_valid2) delta);
                         init_state_copy));
]

let s0 = ~<< init_state

let s1_1 = new_state_plus_delta init_state
    (Skill (init_kill_from_player_valid)) delta

let s1_2 = new_state_plus_delta init_state
    (Skill (init_stun_from_player_valid)) delta

let s1_3 = new_state_plus_delta init_state
    (Skill (init_reg_from_player_valid1)) delta

let s2_1 = new_state_plus_delta s1_2
    (Move (Enemy, 2, 1)) delta

let s2_2 = new_state_plus_delta s1_2
    (Skill init_reg_from_enemy_valid1) delta

let state_tests = [
  "trivial" >:: (fun _ -> assert_equal s0 (~<< init_state_copy));
  "killneutral" >:: (fun _ -> assert_equal (Neutral : allegiance) s1_1.towers.(2).twr_team);
  "kill0" >:: (fun _ -> assert_equal 0 (snd (get_scores s1_1)));
  "stunnedmove" >:: (fun _ -> assert_equal (~<< s1_2).towers.(2)
                         (~<< s2_1).towers.(2));
  "stunnedregen1" >:: (fun _ -> assert_equal (~<< s2_2).towers.(2).twr_troops
                          (~<< s1_2).towers.(2).twr_troops);
  "stunnedregen2" >:: (fun _ -> assert_equal ((~<< s1_2).towers.(2).twr_troops_regen_speed *. 5.)
                                  (~<< s2_2).towers.(2).twr_troops_regen_speed);
]

(* All test lists must be in [tests] *)
let tests = List.flatten [
    helper_tests;
    state_tests;
    state_immutability_tests;
  ]

(*let alltests = "State test suite" >:: tests*)
