type request = { api: Signature4.api; 
		 body: Cohttp_lwt_body.t;
		 headers: Cohttp.Header.t;
		 meth: Cohttp.Code.meth;
		 uri: Uri.t; }
		 
type error = 
  | Generic of Cohttp.Response.t * string
  | No_response
      
type 'a signal = 
  | Error of error
  | Response of 'a
 and 'a t = ('a signal) Lwt.t
			
let error e = Error e
		    
let response r = Response r
			
let error_to_string = function
  | Generic (http, aws) -> Printf.sprintf "HTTP Error %s\n%s" 
					  (Cohttp.Code.string_of_status (Cohttp.Response.status http)) aws
  | No_response -> "No response"
		     
let bind x fn = match_lwt x with
		| Response r -> fn r
		| Error _ as e -> Lwt.return e
					     
let return r = Lwt.return (response r)	
			  
let fail err = Lwt.return (error err)
			  
let run x = match_lwt x with
	    | Error e -> Lwt.fail (Failure (error_to_string e))
	    | Response r -> Lwt.return r
				       
let (>>=) = bind