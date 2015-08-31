; docformat = 'rst'

;+
; Example client side in client/server socket communication. Run this code on
; a client (setting `SERVER` keyword to server addess) and run
; `mg_socket_server_demo` on the server.
;
; http://www.exelisvis.com/Company/PressRoom/Blogs/IDLDataPointDetail/TabId/902/ArtMID/2926/ArticleID/14483/Server-Side-TCPIP-Sockets-Officially-Documented-in-IDL-85-coming-soon.aspx
;
; :Categories:
;   idl85
;
; :Author:
;   Jim Pendleton
;-

;+
; Callback which checks for new data from server.
;
; :Params:
;   id : in, required, type=long
;     timer identifier, there is only one timer on the client so this is not
;     needed, but is required by the timer API
;   info_hash : in, required, type=hash
;     user-defined hash containing information stored between callbacks, e.g.,
;     `lun` and `buffer_count`
;-
pro mg_socket_client_demo_server_callback, id, info_hash
  compile_opt strictarr

  catch, error
  if (error ne 0) then begin
    catch, /cancel
    help, /last_message
    return
  endif

  if (file_poll_input(info_hash['lun'], timeout=0.01)) then begin
    ; The protocol is simply to get 10,000 integers from the server
    ; with each "read". The client doesn't send any data to the server.
    big_buffer = uintarr(100000L)
    length = 0L
    cbuffer = big_buffer

    repeat begin 
      readu, info_hash['lun'], cbuffer, transfer_count=tc
      if (tc gt 0L) then begin
        if (tc ne 0) then begin
          big_buffer[length] = cbuffer[0:tc - 1]
          length += tc
          if (length lt big_buffer.length) then begin
            cbuffer = uintarr(big_buffer.length - length)
          endif
        endif
      endif
    endrep until length ge big_buffer.length

    info_hash['buffer_count']++

    print, info_hash['buffer_count'], $
           total(big_buffer, /preserve_type), $
           format='(%"Got buffer %d, total = %d")'

    if (info_hash['buffer_count'] eq 1000) then begin
      ; Got all 1000 expected buffers of 10,000 integers so stop listening for
      ; data on the socket.
      print, 'Received last buffer'
      free_lun, info_hash['lun'], /force
      return
    endif
  endif else begin
    print, 'no data on socket'
  endelse

  ; get the next buffer
  !null = timer.set(0.001, 'mg_socket_client_demo_server_callback', info_hash)
end


;+
; Main routine running on the client.
;
; :Keywords:
;   server : in, optional, type=string, default=localhost
;     address of server to connect to
;   port : in, optional, type=uint, default=14412US
;     port to connect to
;-
pro mg_socket_client_demo, server=server, port=port
  compile_opt strictarr

  _port = n_elements(port) eq 0L ? 14412US : port
  _server = n_elements(server) eq 0L ? 'localhost' : server

  socket, server_lun, _server, _port, /get_lun, /rawio, $
          connect_timeout=10.0, $
          read_timeout=10.0, $
          write_timeout=10.0
  !null = timer.set(0.001, $
                    'mg_socket_client_demo_server_callback', $
                    hash('lun', server_lun, $
                         'buffer_count',  0L))
end
