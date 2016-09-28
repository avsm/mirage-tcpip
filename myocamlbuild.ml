open Ocamlbuild_plugin

let spf = Printf.sprintf

let rules backends =
  List.iter (fun backend ->
    rule (spf "mirage-cc: %%.mirlib -> %%_%s.a" backend)
    ~dep:"%.mirlib"
    ~prod:(spf "%%_%s.a" backend)
    begin fun env build ->
      let mirlib = env "%.mirlib" in
      let archive = env (spf "%%_%s.a" backend) in
      let objs =
        let dir = Pathname.dirname mirlib in
        string_list_of_file mirlib |>
        List.map (fun file -> [Pathname.concat dir (file^"_"^backend^".o")])
      in
      let results = List.map Outcome.good (build objs) in
      Seq [
        rm_f archive;
        Cmd (S [ A "ar"; A "rc"; P archive; Command.atomize_paths results])
      ]
    end;
    let env_var = spf "%s_CFLAGS" (String.uppercase_ascii backend) in
    let env_cflags = getenv ~default:"" env_var in
    let global_cflags = getenv ~default:"" "CFLAGS" in
    let cc = getenv ~default:"cc" "CC" in
    rule (spf "mirage-cc: _stubs.c -> _stubs_%s.o" backend)
      ~dep:"%_stubs.c"
      ~prod:(spf "%%_stubs_%s.o" backend)
      begin fun env _ ->
        let c = env "%_stubs.c" in
        let o = env (spf "%%_stubs_%s.o" backend) in
        Cmd (S [A cc; A "-c"; A "-o"; P o; Sh global_cflags; Sh env_cflags;
          T (tags_of_pathname c ++ "compile" ++ "mirage-cc");
          P c])
    end
  ) backends;
  rule ("mirage-cc: %.mirlib -> %.mira")
    ~dep:"%.mirlib"
    ~prod:"%.mira"
    begin fun env build ->
      let mirlib = env "%.mirlib" in
      let mira = env "%.mira" in
      let targets =
        let dir = Pathname.dirname mirlib in
        let base = Pathname.(remove_extension (basename mirlib)) in
        List.map (fun b -> [Pathname.concat dir (base^"_"^b^".a")]) backends
      in
      let results = List.map Outcome.good (build targets) in
      Echo ((List.map (fun r -> r ^ "\n") results), mira)
    end

let () = dispatch @@ function
  | After_rules -> rules ["xen";"unix";"solo5"]
  | _ -> ()
