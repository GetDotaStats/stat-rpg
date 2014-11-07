package  {

	import flash.display.MovieClip;
	import flash.net.Socket;
    import flash.utils.ByteArray;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
	
	import com.adobe.serialization.json.JSONEncoder;
	
    public class StatsCollection extends MovieClip {
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;
		
		var SteamID:String;

		var sock:Socket;
		var json:String;
		
		var RPG_ENABLED:Boolean = false;

		var SERVER_ADDRESS:String = "176.31.182.87";
		var SERVER_PORT:Number = 4444;
		var SERVER_ADDRESS_RPG:String = "176.31.182.87";
		var SERVER_PORT_RPG:Number = 4446;

        public function onLoaded() : void {
            // Tell the user what is going on
            trace("##Loading StatsCollection...");

            // Reset our json
            json = '';

            // Load KV
            var settings = globals.GameInterface.LoadKVFile('scripts/stat_collection.kv');  
            // Load the live setting
            var live:Boolean = (settings.live == "1");

            // Load the settings for the given mode
            if(live) {
                // Load live settings
                SERVER_ADDRESS = settings.SERVER_ADDRESS_LIVE;
                SERVER_PORT = parseInt(settings.SERVER_PORT_LIVE);

                // Tell the user it's live mode
                trace("StatsCollection is set to LIVE mode.");
            } else {
                // Load live settings
                SERVER_ADDRESS = settings.SERVER_ADDRESS_TEST;
                SERVER_PORT = parseInt(settings.SERVER_PORT_TEST);

                // Tell the user it's test mode
                trace("StatsCollection is set to TEST mode.");
            }
			if (settings.SERVER_ADDRESS_RPG != null) {
				RPG_ENABLED = true;
				SERVER_ADDRESS_RPG = settings.SERVER_ADDRESS_RPG;
				SERVER_PORT_RPG = parseInt(settings.SERVER_PORT_RPG);
				trace("RPG was set to "+SERVER_ADDRESS_RPG+":"+SERVER_PORT_RPG);
			}
            // Log the server
            trace("Server was set to "+SERVER_ADDRESS+":"+SERVER_PORT);

            // Hook the stat collection event
            gameAPI.SubscribeToGameEvent("stat_collection_part", this.statCollectPart);
            gameAPI.SubscribeToGameEvent("stat_collection_send", this.statCollectSend);
			gameAPI.SubscribeToGameEvent("stat_collection_steamID", this.statCollectSteamID);
        }
		private function ServerConnect(serverAddress:String, serverPort:int) {
			// Tell the client
			trace("##STATS Sending payload:");
			trace(json);

            // Create the socket
			sock = new Socket();
			sock.timeout = 10000; //10 seconds is fair..
			// Setup socket event handlers
			sock.addEventListener(Event.CONNECT, socketConnect);

			try {
				// Connect
				sock.connect(serverAddress, serverPort);
			} catch (e:Error) {
				// Oh shit, there was an error
				trace("##STATS Failed to connect!");

				// Return failure
				return false;
			}
		}
		private function socketConnect(e:Event) {
			// We have connected successfully!
            trace('Connected to the server!');

            // Hook the data connection
            //sock.addEventListener(ProgressEvent.SOCKET_DATA, socketData);
			var buff:ByteArray = new ByteArray();
			writeString(buff, json + '\r\n');
			sock.writeBytes(buff, 0, buff.length);
            sock.flush();
		}
		private static function writeString(buff:ByteArray, write:String){
			trace("Message: "+write);
			trace("Length: "+write.length);
            buff.writeUTFBytes(write);
        }
		
		//
		// RPG API
		//
		
		public function SaveData(modID:String, saveID:int, jsonData:String) {
			if (RPG_ENABLED == false) {
				return;
			}
			var info:Object = {
				type     : "SAVE",
				modID    : modID,
				steamID  : SteamID,
				saveID   : saveID,
				jsonData : jsonData
			};
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS_RPG, SERVER_PORT_RPG);
		}
		public function DeleteSave(modID:String, saveID:int) {
			if (RPG_ENABLED == false) {
				return;
			}
			var info:Object = {
				type    : "DELETE",
				modID   : modID,
				steamID : SteamID,
				saveID  : saveID
			};
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS_RPG, SERVER_PORT_RPG);
		}
		
		public function GetSaves(modID:String) {
			if (RPG_ENABLED == false) {
				return;
			}
			var info:Object = {
				type    : "LOAD",
				modID   : modID,
				steamID : SteamID
			};
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS_RPG, SERVER_PORT_RPG);
			//TODO: Event handler to receive the json list back
		}
		//
		// Event Handlers 
		//
		
        public function statCollectPart(args:Object) {
            // Tell the client
            trace("##STATS Part of that stat data recieved:");
            trace(args.data);

            // Store the extra data
            json = json + args.data;
        }
		public function statCollectSend(args:Object) {
			ServerConnect(SERVER_ADDRESS, SERVER_PORT);
		}
		public function statCollectSteamID(args:Object) {
			SteamID = args[globals.Players.GetLocalPlayer()];
			trace("STEAM ID: "+SteamID);
		}
    }
}
