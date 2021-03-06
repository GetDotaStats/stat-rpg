﻿package  {

	import flash.display.MovieClip;
	import flash.net.Socket;
    import flash.utils.ByteArray;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
	
	import com.adobe.utils.DateUtil;
	
	import com.adobe.serialization.json.JSONEncoder;
	import com.adobe.serialization.json.JSONParseError;
	import com.adobe.serialization.json.JSONDecoder;
	
    public class StatsCollectionRPG extends MovieClip {
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;
		
		var SteamID:Number;

		var sock:Socket;
		var callback:Function;
		
		var json:String;

		var SERVER_ADDRESS:String = "176.31.182.87";
		var SERVER_PORT:Number = 4444;

        public function onLoaded() : void {
            // Tell the user what is going on
            trace("##Loading StatsCollection...");

            // Reset our json
            json = '';

            // Load KV
            var settings = globals.GameInterface.LoadKVFile('scripts/stat_collection_rpg.kv');  
            // Load the live setting
            var live:Boolean = (settings.live == "1");

            // Load the settings for the given mode
            if(live) {
                // Load live settings
                SERVER_ADDRESS = settings.SERVER_ADDRESS_LIVE;
                SERVER_PORT = parseInt(settings.SERVER_PORT_LIVE);

                // Tell the user it's live mode
                trace("StatsCollectionRPG is set to LIVE mode.");
            } else {
                // Load live settings
                SERVER_ADDRESS = settings.SERVER_ADDRESS_TEST;
                SERVER_PORT = parseInt(settings.SERVER_PORT_TEST);

                // Tell the user it's test mode
                trace("StatsCollectionRPG is set to TEST mode.");
            }
            // Log the server
            trace("Server was set to "+SERVER_ADDRESS+":"+SERVER_PORT);

            // Hook the stat collection event
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
			sock.addEventListener(ProgressEvent.SOCKET_DATA, socketData);

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
		private function socketData(e:ProgressEvent) {
			trace("Received data, length: "+sock.bytesAvailable);
			var str:String = sock.readUTFBytes(sock.bytesAvailable);
			trace("Received string: "+str);
			try {
				var test = new JSONDecoder(str, false).getValue();
				if (test["result"] == "failure") {
					trace("###STATS_RPG WHAT DID YOU JUST DO?!?!?!");
					trace("###STATS_RPG ERROR: "+test["error"]);
					switch(test["type"]) {
						case "save":
						case "delete":
							callback(false);
						break;
						case "list":
							callback(new Array());
						break;
						case "load":
						case "create":
							callback(null);
						break;
					}
					return;
				}
				switch(test["type"]) {
					case "save":
					case "delete":
						callback(true);
					break;
					case "list":
						var output:Array = new Array();
						for each (var entry:Object in test["jsonArray"]) {
							output.push({
										"saveID" : entry.saveID,
										"metaData" : new JSONDecoder(entry.metaData, false).getValue(),
										"dateRecorded" : DateUtil.parseW3CDTF(entry.dateRecorded)
										});
						}
						callback(output);
					break;
					case "load":
						trace("We had a load reply");
						callback(test["jsonData"]);
					break;
					case "create":
						callback(test["saveID"]);
					break;
					default:
						trace("###STATS_RPG Unknown packet: "+test["type"]);
					break;
				}
			} catch (error:JSONParseError) {
				trace("###STATS_RPG HELP ME...");
				trace(str);
			}
		}
		private static function writeString(buff:ByteArray, write:String){
			trace("Message: "+write);
			trace("Length: "+write.length);
            buff.writeUTFBytes(write);
        }
		
		//
		// RPG API
		//
		
		public function SaveData(modID:String, saveID:int, jsonData:Object, metaData:*, callback:Function) {
			this.callback = callback;
			var info:Object = {
				type     : "SAVE",
				modID    : modID,
				steamID  : SteamID,
				saveID   : saveID,
				jsonData : jsonData
			};
			if (metaData is String) {
				info.metaData = metaData;
			} else {
				info.metaData = new JSONEncoder(metaData).getString();
			}
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS, SERVER_PORT);
		}
		public function DeleteSave(modID:String, saveID:int, callback:Function) {
			this.callback = callback;
			var info:Object = {
				type    : "DELETE",
				modID   : modID,
				steamID : SteamID,
				saveID  : saveID
			};
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS, SERVER_PORT);
		}
		
		public function GetSave(modID:String, saveID:int, callback:Function) {
			this.callback = callback;
						
			var info:Object = {
				type    : "LOAD",
				modID   : modID,
				steamID : SteamID,
				saveID  : saveID
			};
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS, SERVER_PORT);
			//TODO: Event handler to receive the json list back
		}
		public function GetList(modID:String, callback:Function) {
			this.callback = callback;
			
			var info:Object = {
				type    : "LIST",
				modID   : modID,
				steamID : SteamID
			};
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS, SERVER_PORT);
		}
		public function CreateSave(modID:String, callback:Function) {
			this.callback = callback;
			
			var info:Object = {
				type    : "CREATE",
				modID   : modID,
				steamID : SteamID
			};
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS, SERVER_PORT);
		}
		
		//
		// Event Handlers 
		//
		public function statCollectSteamID(args:Object) {
			 var splitMsg:Array = args.ids.split(",");
			 this.SteamID = Number(splitMsg[this.globals.Players.GetLocalPlayer()]);
			// this.UserName = this.globals.Players.GetPlayerName(this.globals.Players.GetLocalPlayer());
			 trace("STEAM ID: " + this.SteamID);
			//trace("USERNAME: " + this.UserName);
		}
    }
}
