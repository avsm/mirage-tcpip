val src : Logs.src
module Log : Logs.LOG
module Make : functor (Time : V1_LWT.TIME) (Random : V1.RANDOM) (Udp : V1_LWT.UDPV4) -> sig
  type offer = {
    ip_addr : Ipaddr.V4.t;
    netmask : Ipaddr.V4.t option;
    gateways : Ipaddr.V4.t list;
    dns : Ipaddr.V4.t list;
    lease : int32;
    xid : int32;
  }
  type state =
    Disabled
  | Request_sent of int32
  | Offer_accepted of offer
  | Lease_held of offer
  | Shutting_down
  type t = {
    udp : Udp.t;
    mac : Macaddr.t;
    mutable state : state;
    new_offer : offer -> unit Lwt.t;
  }

  [%%cstruct
  type dhcp = {
      op: uint8_t;
      htype:  uint8_t;
      hlen:   uint8_t;
      hops:   uint8_t;
      xid:    uint32_t;
      secs:   uint16_t;
      flags:  uint16_t;
      ciaddr: uint32_t;
      yiaddr: uint32_t;
      siaddr: uint32_t;
      giaddr: uint32_t;
      chaddr: uint8_t [@len 16];
      sname:  uint8_t [@len 64];
      file:   uint8_t [@len 128];
      cookie: uint32_t;
    } [@@big_endian]
  ]
  [%%cenum
  type mode =
    | BootRequest [@id 1]
    | BootReply
    [@@uint8_t]
  ]

  val output_broadcast :
    t ->
    xid:Cstruct.uint32 ->
    yiaddr:Ipaddr.V4.t ->
    siaddr:Ipaddr.V4.t -> options:Dhcpv4_option.Packet.p -> unit Udp.io

  val input : t -> src:'a -> dst:'b -> src_port:'c -> Cstruct.t -> unit Udp.io
  val start_discovery : t -> unit Lwt.t
  val dhcp_thread : t -> unit Lwt.t
  val pp_opt : (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a option -> unit
  val create : Macaddr.t -> Udp.t -> t * offer Lwt_stream.t
  val listen : t -> dst_port:int -> (src:'a -> dst:'b -> src_port:'c -> Cstruct.t -> unit Udp.io) option
end
