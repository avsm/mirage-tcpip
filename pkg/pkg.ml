#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
open Topkg

module Build = struct

  let xen_cflags_pkg_config () =
    Conf.tool "pkg-config" `Build_os |> fun cflags -> 
    OS.Cmd.run_out ~err:"pkg.log" Cmd.(cflags % "--static" % "mirage-xen" % "--cflags") |> fun out ->
    OS.Cmd.out_string ~trim:true out |> function
    | Ok (cflags, (_, `Exited 0)) -> Ok (Some cflags)
    | Ok (cflags, (_, `Exited _)) -> Ok None
    | Error _ -> Ok None

  let xen_cflags_key =
    Conf.(discovered_key
      ~docv:"CFLAGS for Xen C build"
      ~doc:"XEN_CFLAGS value"
      ~env:"XEN_CFLAGS" "xen-cflags"
      ~absent:xen_cflags_pkg_config
      (some string))
end

let xen = Conf.with_pkg ~default:false "xen" 
let unix = Conf.with_pkg ~default:true "base-unix"

let () =
  Pkg.describe "tcpip" @@ fun c ->
  let xen = Conf.value c xen in
  let xen_cflags = Conf.value c Build.xen_cflags_key in 
  Ok [
   Pkg.mllib "src/ethif/ethif.mllib";
   Pkg.mllib "src/arpv4/arpv4.mllib";
   Pkg.mllib "src/ipv4/ipv4.mllib";
   Pkg.mllib "src/ipv6/ipv6.mllib";
   Pkg.mllib "src/checksum/tcpip_checksum.mllib";
   Pkg.mllib "src/icmpv4/icmpv4.mllib";
   Pkg.mllib "src/udpv4/udp.mllib";
   Pkg.mllib "src/tcp/tcp.mllib";
   Pkg.mllib "src/dhcpv4/dhcp_clientv4.mllib";
   Pkg.mllib "src/stack/tcpip_stack_direct.mllib";
  ] 
