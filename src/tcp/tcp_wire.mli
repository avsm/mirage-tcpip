[%%cstruct
type tcp = {
    src_port:   uint16_t;
    dst_port:   uint16_t;
    sequence:   uint32_t;
    ack_number: uint32_t;
    dataoff:    uint8_t;
    flags:      uint8_t;
    window:     uint16_t;
    checksum:   uint16_t;
    urg_ptr:    uint16_t;
  } [@@big_endian]
]

[%%cstruct
type tcpv4_pseudo_header = {
    src:   uint32_t;
    dst:   uint32_t;
    res:   uint8_t;
    proto: uint8_t;
    len:   uint16_t;
  } [@@big_endian]
]

val get_data_offset : Cstruct.t -> int
val set_data_offset : Cstruct.t -> int -> unit

val get_fin : Cstruct.t -> bool
val get_syn : Cstruct.t -> bool
val get_rst : Cstruct.t -> bool
val get_psh : Cstruct.t -> bool
val get_ack : Cstruct.t -> bool
val get_urg : Cstruct.t -> bool
val get_ece : Cstruct.t -> bool
val get_cwr : Cstruct.t -> bool

val set_fin : Cstruct.t -> unit
val set_syn : Cstruct.t -> unit
val set_rst : Cstruct.t -> unit
val set_psh : Cstruct.t -> unit
val set_ack : Cstruct.t -> unit
val set_urg : Cstruct.t -> unit
val set_ece : Cstruct.t -> unit
val set_cwr : Cstruct.t -> unit
