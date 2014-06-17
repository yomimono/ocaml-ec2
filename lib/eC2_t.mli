
type time = string
	      
type successful = bool
		    
type create_snapshot = { snapshot: string;
			 volume: string;
			 status: string; (* pending|completed|error *)
			 start_time: string;
			 progress: string;
			 owner: string;
			 size: string;
			 encrypted: bool;
			 description: string }
			 
type console_output = { instance: string;
			timestamp: time;
			output: string }
			
type instance_state = { code: int; name: string; }
(* name: pending|running|shutting-down... code: 16-bit unsigned
see http://docs.aws.amazon.com/AWSEC2/latest/APIReference/ApiReference-ItemType-InstanceStateType.html *)
			
type running_instance = { id: string;
			  image: string;
			  state: instance_state;
			  private_dns: string;
			  public_dns: string;
			  reason: string;
			  key_name: string;
			  ami_launch_index: string;
			  (*product_codes: productCodesSetItemType*)
			  instance_type: string;
			  launch_time: time;
			  (*placement:*)
			  kernel: string;
			(* TODO there are more fields! *)
			}
			  
type run_instances = { reservation: string;
		       owner: string;
		       (*security_groups:*)
		       instances: running_instance list;
		       requester: string }
		       
type instance_state_change = { id: string; 
			       current: instance_state;
			       previous: instance_state; }
			       
			       
type region = { name: string; endpoint: string }
type describe_regions = region list