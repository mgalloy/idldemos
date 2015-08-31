; docformat = 'rst'

;+
; Example server side in client/server socket communication. Run this code on
; a server and run `mg_socket_client_demo` on the client (making sure to set
; the `SERVER` keyword to the address of the server running this code).
;
; :Categories:
;   idl85
;
; http://www.exelisvis.com/Company/PressRoom/Blogs/IDLDataPointDetail/TabId/902/ArtMID/2926/ArticleID/14483/Server-Side-TCPIP-Sockets-Officially-Documented-in-IDL-85-coming-soon.aspx
;
; :Author:
;   Jim Pendleton
;-


;+
; Callback waiting for data from a client connection that has already been
; established.
;
; :Params:
;   id : in, required, type=long
;     timer identifier
;   info_hash : in, required, type=long
;     user-defined hash containing information stored between callbacks, e.g.,
;     `buffer_count`, `lun`, and `listener_lun`
;-
pro mg_socket_server_demo_client_callback, id, info_hash
  compile_opt strictarr

  catch, error
  if (error ne 0) then begin
    catch, /cancel
    ; Unable to send for some reason. Try HELP, /LAST_MESSAGE if you want to
    ; know why. Try again.
    !null = timer.set(0.01, 'mg_socket_server_demo_client_callback', info_hash)
    return
  endif

  ; Send 100,000 random numbers as integers to the client.
  buffer = uint(randomu(seed, 100000L) * 5.0)
  writeu, info_hash['lun'], buffer, transfer_count=tc
  if (tc ne 0) then begin
    flush, info_hash['lun']
    info_hash['buffer_count']++
    print, info_hash['buffer_count'], total(buffer, /preserve_type), $
           format='(%"wrote buffer %d to client, total = %d")'
  endif else begin
    if (tc ne buffer.length) then begin
      print, tc, format='(%"Only sent %d values")'
    endif
  endelse
  if (info_hash['buffer_count'] eq 1000L) then begin
    ; Only reply to the first 1000 requests, then close down the socket.
    free_lun, info_hash['lun'], /force
    !null = timer.set(0.1, 'mg_socket_server_demo_listener_callback', $
                      info_hash['listener_lun'])
    print, 'closed client socket, listening for new connection requests...'
  endif else begin
    !null = timer.set(0.01, 'mg_socket_server_demo_client_callback', info_hash)
  endelse
end 


;+
; Callback waiting to make a connection with a client.
;
; :Params:
;   id : in, required, type=long
;     timer identifier
;   listener_lun : in, required, type=long
;     logical unit number for the socket that the server is listening on
;-
pro mg_socket_server_demo_listener_callback, id, listener_lun
  compile_opt strictarr

  status = file_poll_input(listener_lun, timeout=0.1)
  if (status) then begin
    print, 'Made a connection, starting client connection...'
    socket, client_lun, accept=listener_lun, /get_lun, /rawio, $
            connect_timeout=30.0, read_timeout=30.0, write_timeout=30.0
    !null = timer.set(0.01, 'mg_socket_server_demo_client_callback', $
                      Hash('lun', client_lun, $
                           'buffer_count', 0L, $
                           'listener_lun', listener_lun))
  endif else begin
    !null = timer.set(0.1, 'mg_socket_server_demo_listener_callback', $
                      listener_lun)
  endelse
end


;+
; Main routine running on the server.
;
; :Keywords:
;   port : in, optional, type=uint, default=14412US
;     port to listen on
;
pro mg_socket_server_demo, port=port
  compile_opt strictarr

  _port = n_elements(port) eq 0L ? 14412US : port
  socket, listener_lun, _port, /listen, /get_lun, /rawio, $
          read_timeout=60.0, write_timeout=60.0
  !null = timer.set(0.1, 'mg_socket_server_demo_listener_callback', $
                    listener_lun)
end
