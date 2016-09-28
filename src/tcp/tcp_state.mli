(*
 * Copyright (c) 2012 Balraj Singh <bs375@cl.cam.ac.uk>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

type action =
  | Passive_open
  | Recv_rst
  | Recv_synack of Tcp_sequence.t
  | Recv_ack of Tcp_sequence.t
  | Recv_fin
  (* | Recv_finack of Tcp_sequence.t *)
  | Send_syn of Tcp_sequence.t
  | Send_synack of Tcp_sequence.t
  | Send_rst
  | Send_fin of Tcp_sequence.t
  | Timeout

val pp_action: Format.formatter -> action -> unit

type tcpstate =
  | Closed
  | Listen
  | Syn_rcvd of Tcp_sequence.t
  | Syn_sent of Tcp_sequence.t
  | Established
  | Close_wait
  | Last_ack of Tcp_sequence.t
  | Fin_wait_1 of Tcp_sequence.t
  | Fin_wait_2 of int
  | Closing of Tcp_sequence.t
  | Time_wait
  | Reset

val pp_tcpstate : Format.formatter -> tcpstate -> unit

type close_cb = unit -> unit

type t

val state : t -> tcpstate
val t : on_close:close_cb -> t

val pp: Format.formatter -> t -> unit

module Make(Time : V1_LWT.TIME) : sig
  val fin_wait_2_time : int64
  val time_wait_time : int64
  val finwait2timer : t -> int -> int64 -> unit Lwt.t
  val timewait : t -> int64 -> unit Lwt.t
  val tick : t -> action -> unit
end
