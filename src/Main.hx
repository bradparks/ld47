import Data;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;
	public var ca : dn.heaps.Controller.ControllerAccess;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

        createRoot(s);

		// Engine settings
		hxd.Timer.wantedFPS = Const.FPS;
		engine.backgroundColor = 0xff<<24|Const.DARK_COLOR;
        #if( hl && !debug )
        engine.fullScreen = true;
        #end

		// Resources
		#if(hl && debug)
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed();
        #end

        // Hot reloading (CastleDB)
		#if debug
        hxd.res.Resource.LIVE_UPDATE = true;
        hxd.Res.data.watch(function() {
            delayer.cancelById("cdb");

            delayer.addS("cdb", function() {
            	Data.load( hxd.Res.data.entry.getBytes().toString() );
            	if( Game.ME!=null )
                    Game.ME.onCdbReload();
            }, 0.2);
        });

        // Hot reloading (LEd)
        hxd.Res.world.world.watch(function() {
            delayer.cancelById("led");

            delayer.addS("led", function() {
            	if( Game.ME!=null )
                    Game.ME.onLedReload();
            }, 0.2);
        });
		#end

		// Assets & data init
		Assets.init();
		new ui.Console(Assets.fontTiny, s);
		Lang.init("en");
		Data.load( hxd.Res.data.entry.getText() );

		// Game controller
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(AXIS_LEFT_Y_NEG, Key.UP, Key.Z, Key.W);
		controller.bind(AXIS_LEFT_Y_POS, Key.DOWN, Key.S);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(A, Key.UP, Key.Z, Key.W);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.N);

		// Start
		#if js
			new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.fontMedium);
			delayer.addF( startIntro, 1 );
		#else
			#if debug
			startGame();
			#else
			startIntro();
			#end
		#end
	}

	public function startIntro() {
		new Intro(false);
	}

	public function startGame() {
		if( Game.ME!=null ) {
			Game.ME.destroy();
			delayer.addF(function() {
				new Game();
			}, 5);
		}
		else
			new Game();
	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_WID>0 )
			Const.SCALE = M.ceil( w()/Const.AUTO_SCALE_TARGET_WID );
		else if( Const.AUTO_SCALE_TARGET_HEI>0 )
			Const.SCALE = M.ceil( h()/Const.AUTO_SCALE_TARGET_HEI );

		Const.UI_SCALE = Const.SCALE;
	}

    override function update() {
		Assets.tiles.tmod = tmod;
        super.update();
    }
}