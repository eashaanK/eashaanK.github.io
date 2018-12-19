open Types

let find_ui_ref interface id =
  if List.mem_assoc id interface then (
    Some (List.assoc id interface)
  ) else (
    None
  )

let get_label_prop label : label_property=
  match label with
  | Label (prop,pos,size) -> prop
  | _ -> failwith "Label property not found: Not a label"

let tick interface input =
  (* make updates to interface *)
  List.iter (fun (id,uref) ->
    match !uref with
    | Button (prop, pos, size, nsc) -> begin
        (* If button is disabled, then ignore it *)
        if prop.btn_state = Disabled then
          ()
        else begin
          let _ =
          (* Check if mouse is inside the button *)
          if Physics.point_inside input.mouse_pos pos size then begin
            if input.mouse_state = Released then (
              prop.btn_state <- Clicked
            )
            else if input.mouse_state = Pressed || prop.btn_state = Depressed then (
              prop.btn_state <- Depressed
            )
          end
          else 
            prop.btn_state <- Neutral
          in
          uref := Button (prop, pos, size, nsc);
          ()
        end
      end
    | Label (label_prop, pos, size) -> begin
        uref := Label (label_prop, pos, size);
        ()
      end
    | Panel (sprite, pos, size) -> begin
        let new_sprite = Sprite.tick sprite !Renderer.delta in
        uref := Panel (new_sprite, pos, size);
        ()
      end
    | SpellBox (prop, pos, size, skill) -> 
      begin
        () (* Will be handled in state *)
      end
  ) interface;
  interface

let fps_label = Label ({text="0";color={r=0;g=0;b=0;a=0.25};font_size=20},
                       {x=Renderer.width-.30.;y=30.;},
                       {w=30.;h=30.})
