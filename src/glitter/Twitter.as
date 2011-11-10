package glitter
{
	import com.swfjunkie.tweetr.Tweetr;
	import com.swfjunkie.tweetr.events.TweetEvent;
	import com.swfjunkie.tweetr.oauth.OAuth;
	import com.swfjunkie.tweetr.oauth.events.OAuthEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.net.SharedObject;

	[Event(name="ready")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	[Event(name="authError", type="flash.events.ErrorEvent")]
	public class Twitter extends EventDispatcher
	{
		private static const CONSUMER_KEY:String = "TWITTER CONSUMER KEY HERE";
		private static const CONSUMER_SECRET:String = "TWITTER CONSUMER SECRET HERE";
		
		private var tweetr: Tweetr
		private var oauth:OAuth;
		private var htmlLoader:HTMLLoader;
		private var cachedData:SharedObject;
		
		public function Twitter()
		{
			tweetr = new Tweetr();
			tweetr.serviceHost = "http://tweetr.swfjunkie.com/proxy";
			tweetr.addEventListener(TweetEvent.FAILED,onTweetError);
			
			oauth = new OAuth();
			oauth.consumerKey = CONSUMER_KEY;
			oauth.consumerSecret = CONSUMER_SECRET;
			oauth.callbackURL = "http://netsyndicate.net/";
			oauth.pinlessAuth = true;
			oauth.addEventListener(OAuthEvent.COMPLETE,onOAuthResponse);
			oauth.addEventListener(OAuthEvent.ERROR,onOAuthError);
			
		}
		
		public function get api():Tweetr
		{
			return tweetr;
		}
		
		public function init():void 
		{
			this.cachedData = SharedObject.getLocal("GlitterToken");
			
			if(cachedData.data.token){
				oauth.oauthToken = cachedData.data.token;
				oauth.oauthTokenSecret = cachedData.data.tokenSecret;
				tweetr.oAuth = oauth;
				dispatchEvent(new Event('ready'));
			}
			else
			{
				this.htmlLoader = HTMLLoader.createRootWindow(true, null, true, new Rectangle(50,50, 780, 500));
				this.htmlLoader.stage.nativeWindow.alwaysInFront = true;
				oauth.htmlLoader = this.htmlLoader;
				oauth.getAuthorizationRequest();
			}
		}
		
		public function clearCache():void{
			if (this.cachedData){
				this.cachedData.clear();
			}
		}
		
		private function onOAuthResponse(e:OAuthEvent):void 
		{
			if(oauth.oauthToken){
				this.htmlLoader.stage.nativeWindow.close();
				
				cachedData.data.token = oauth.oauthToken;
				cachedData.data.tokenSecret = oauth.oauthTokenSecret;
				cachedData.flush();
				
				tweetr.oAuth = oauth;
				dispatchEvent(new Event("ready"));
			}
		}
		
		private function onOAuthError(e:OAuthEvent):void 
		{
			dispatchEvent(new ErrorEvent('authError',false,false,e.text));
		}

		private function onTweetError(e:TweetEvent):void 
		{
			dispatchEvent(new ErrorEvent('error',false,false,e.info));
		}
				
	}
}