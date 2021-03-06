(* This program will register an Amazon Machine Image given an image such as `mirage.img`.

The commented function at the end of this file will register an AMI and launch it.

If you are in need of a script to convert unikernels to images, see
https://gist.githubusercontent.com/moonlightdrive/94a8a254f7ac7f6ed479/raw/5b5338518c3d741c8526472e5165287087a46971/xen2img.sh 
 *)

open EC2
open EC2_t

let image = "my.img"
let my_key = "myprivatekey.pem"
let my_cert = "mycert.pem"
let region = US_WEST_2
let my_bucket = "mybucket"
let kernel = "aki-fc8f11cc"

let register_ami img_file key cert bucket () =
  print_endline "Bundling image...";
  let (manifest_path, part_paths) as files = Bundle.bundle_img ~key ~cert ~kernel img_file |> Lwt_main.run in
  print_endline "Uploading bundle (this may take a while)...";
  ignore @@ List.map Lwt_main.run @@ Bundle.upload ~bucket files ~region;
  print_endline "Registering AMI...";
  let img_path = 
    let kernel =  manifest_path in
    Printf.sprintf "%s%s" bucket kernel in
  AMI.register_image ~name:"ocaml-ec2" ~img_path ~region ()

let launch_instance img key cert bucket =
  Monad.bind 
    (register_ami img key cert bucket ())
    (fun id -> Instances.run id ~region ())

(* Register an AMI without launching *)
let _ = 
  let ami = Lwt_main.run @@ Monad.run @@ register_ami image my_key my_cert my_bucket () in
  print_endline @@ 
    Printf.sprintf "Registered AMI.\nLaunch this instance with `Instances.run \"%s\" ()`"
		   (ImageID.to_string ami)
    
(* Registers AMI & launches an instance *)
(*
let _ = 
  let running = Lwt_main.run @@ Monad.run @@ launch_instance image my_key my_cert my_bucket in
  running.instances |>
    List.map (fun i -> print_endline @@ Printf.sprintf "Launched instance %s" i.Running_instance.id) 
 *)
