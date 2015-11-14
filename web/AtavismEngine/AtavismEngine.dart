library AtavismEngine;

import 'dart:html' as html;
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';

part 'TextureLoader.dart';
part 'Weapons.dart';
part 'BattleUnit.dart';
part 'BattleSystem.dart';


class AtavismEngine {

  html.CanvasElement canvasElement;
  html.CanvasRenderingContext2D ctx;

  num start = -1;
  num previousTimeStamp = 0;

  bool isRunning = false;

  BattleSystem battleSystem;

  AtavismEngine(this.canvasElement) {
    this.ctx = this.canvasElement.getContext('2d');
    this.battleSystem = new BattleSystem(this);
  }

  /// Run the engine
  void run() {
    this.isRunning = true;

    TextureLoader.load();

    BattleUnit battleUnit = new BattleUnit();
    battleSystem.queueAddUnit(battleUnit);

    battleUnit = new BattleUnit();
    battleUnit.position.setValues(7.0, 7.0);
    battleSystem.queueAddUnit(battleUnit);

    battleUnit = new BattleUnit();
    battleUnit.position.setValues(-2.0, -2.0);
    battleSystem.queueAddUnit(battleUnit);

    battleUnit = new BattleUnit();
    battleUnit.imageElement = html.querySelector("#marine");
    battleUnit.position.setValues(4.0, -4.0);
    battleSystem.queueAddUnit(battleUnit);

    battleUnit = new BattleUnit();
    battleUnit.position.setValues(-3.0, -4.0);
    battleSystem.queueAddUnit(battleUnit);

    math.Random r = new math.Random();
    for (num i = 0; i < 8; i++) {
      battleUnit = new BattleUnit();
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

    beginDrawing(dt);
    gameLoop(dt);
    endDrawing();

    html.window.animationFrame.then(loop);
  }

  void gameLoop(num dt) {
    battleSystem.update(dt);
  }

  void beginDrawing(num dt) {
    ctx.save();
    ctx.fillStyle = '#fefefe';
    ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    ctx.translate(canvasElement.width / 2, canvasElement.height / 2);
    ctx.scale(25, 25);
  }

  void endDrawing() {
    ctx.restore();
  }
}