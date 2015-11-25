part of atavism_engine;

class AtavismEngine {

  Stage stage;
  WebGLRenderer renderer;
  DisplayObjectContainer sceneRoot;

  num start = -1;
  num previousTimeStamp = 0;
  num frameNumber = 0;

  bool isRunning = false;

  BattleSystem battleSystem;

  AtavismEngine(html.Element container) {
    this.stage = new Stage(new Color.createRgba(200, 200, 200));
    this.renderer = new WebGLRenderer(width: 400, height: 400, transparent: false, antialias: false, preserveDrawingBuffer: false);

    this.sceneRoot = new DisplayObjectContainer();

    sceneRoot.position.x = 200;
    sceneRoot.position.y = 200;
    sceneRoot.scale.x = 25.0;
    sceneRoot.scale.y = 25.0;

    stage.addChild(sceneRoot);

    container.append(renderer.view);

    renderer.view.addEventListener('contextmenu', (html.Event ev) {
      ev.preventDefault();
    });

    this.battleSystem = new BattleSystem(this);
  }

  /// Run the engine
  run() async {
    this.isRunning = true;

    await TextureLoader.load();

    BattleUnit battleUnit;

    for (num i = -1; i <= 1; i++) {
      battleUnit = new BattleUnit(MARINE, 0);
      battleUnit.position.setValues(i * 1.5, 0.0);
      battleSystem.queueAddUnit(battleUnit);
    }

    math.Random r = new math.Random();
    for (num i = 0; i < 24; i++) {
      battleUnit = new BattleUnit(ZUG, 1);
      battleUnit.team = 1;
      battleUnit.position.setValues(r.nextDouble() * 20 - 10, r.nextDouble() * 20 - 10);
      battleSystem.queueAddUnit(battleUnit);
    }

      html.window.animationFrame.then(loop);
  }

  void loop(num timeStamp) {
    if (start == -1) {
      start = timeStamp;
    }
    num dt = (timeStamp - previousTimeStamp) / 1000;
    previousTimeStamp = timeStamp;

    gameLoop(dt);

    beginDrawing(dt);
    renderer.render(stage);
    endDrawing();

    html.window.animationFrame.then(loop);
  }

  void gameLoop(num dt) {
    battleSystem.update(dt);
  }

  void beginDrawing(num dt) {
    // Camera
    // ctx.translate(canvasElement.width / 2, canvasElement.height / 2);
  }

  void endDrawing() {
  }
}
