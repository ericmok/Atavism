part of atavism_engine;


enum ArmorType {
  LIGHT,
  NORMAL,
  HEAVY,
  BUILDING
}


class Armor {
  ArmorType ARMOR_TYPE = ArmorType.LIGHT;
  num armorAmount = 0;
}

enum Goal {
  IDLE,
  KILL_TARGET,
  WALKING_TO_POINT,
}

class BattleUnit {

  Vector2 temp = new Vector2.zero();

  Vector2 position = new Vector2.zero();
  Vector2 velocity = new Vector2.zero();

  Vector2 separationForce = new Vector2.zero();
  Vector2 enemyAttractionForce = new Vector2.zero();
  Vector2 accumulator = new Vector2.zero();

  num angle = 0;
  num radius = 1;

  num team = 0;

  num maxSpeed = 4;
  num turningAngle = 1;

  Weapon weapon = new Weapon(NORMAL_WEAPON_DEF);
  Armor armor = new Armor();

  num hp = 1;

  num targetAcquisitionRange = 30;
  BattleUnit target = null;

  Vector2 destination = new Vector2.zero();

  Goal action = Goal.IDLE;

  html.ImageElement imageElement = TextureLoader.ZUG_IMAGE;

  BattleUnit() {
  }

  void attack(BattleUnit other) {
  }

  void hurt(Weapon weapon) {
    switch(weapon.weaponDef.attackType) {
      case AttackType.NORMAL:
        break;
      case AttackType.CHEMICAL:
        break;
      case AttackType.PIERCING:
        break;
      case AttackType.MAGICAL:
        break;
      case AttackType.SIEGE:
        break;
    }

    this.hp -= weapon.weaponDef.attackDamage;
  }

  void onAttackCast() {
  }

  void onAttackFail() {
  }

  bool isAlive() {
    return hp > 0;
  }

  BattleUnit findUnitWithinRange(BattleSystem battleSystem, num searchDistance, num dt) {
    bool foundTarget = false;

    num minimumTargetDistance = 10000;
    BattleUnit closestBattleUnit = null;

    // Then look for a target
    for (num i = 0; i < battleSystem.battleUnits.length; i++) {
      BattleUnit battleUnit = battleSystem.battleUnits[i];

      if (this == battleUnit || !battleUnit.isAlive() || this.team == battleUnit.team) {
        continue;
      }

      num distance = position.distanceTo(battleUnit.position);

      if (distance < searchDistance) {

        if (distance < minimumTargetDistance) {
          closestBattleUnit = battleUnit;
          minimumTargetDistance = distance;
          foundTarget = true;
        }
      }
    }

    return closestBattleUnit;
  }

  void resetTarget() {
    target = null;
    action = Goal.IDLE;
  }

  bool resetTargetIfNullOrDead() {
    if (target == null || !target.isAlive()) {
      resetTarget();
      return true;
    }
    return false;
  }

  void update(BattleSystem battleSystem, num dt) {

    // Momentum
    velocity.scale(0.1);
    accumulator.setZero();
    separationForce.setZero();
    enemyAttractionForce.setZero();

    battleSystem.battleUnits.forEach((BattleUnit battleUnit) {
      if (this != battleUnit && this.position.distanceTo(battleUnit.position) < 1) {
        separationForce = position - battleUnit.position;
        num distSq = separationForce.length2 + 0.000001; // To prevent divide by zero
        num distanceScale = 0.5 / (distSq);
        separationForce.normalize();
        separationForce.scale(distanceScale);
        separationForce.copyInto(separationForce);
      }
    });

    accumulator += separationForce;

    weapon.update(dt);
    resetTargetIfNullOrDead();

    if (action == Goal.IDLE) {
      target = findUnitWithinRange(battleSystem, targetAcquisitionRange, dt);
      if (target != null) {
        action = Goal.KILL_TARGET;
      }
    }

    if (action == Goal.KILL_TARGET) {
      if (weapon.isAwaitingOnReady()) {
        if (position.distanceTo(target.position) > weapon.weaponDef.attackRange * 0.9) {
          enemyAttractionForce = target.position - position;
          enemyAttractionForce.normalize();
          accumulator += enemyAttractionForce;
        } else {
          weapon.startSwing();
        }
      }

      if (weapon.isSwinging()) {
        if (target == null || !target.isAlive()) {
          resetTarget();
        }
      }

      if (weapon.isAwaitingOnCasting()) {
        target.hurt(weapon);

        if (!target.isAlive()) {
          battleSystem.queueRemoveUnit(target);
          resetTarget();
        }

        weapon.startCooldown();
      }
    }

    //accumulator.normalize();
    //accumulator.scale(maxSpeed.toDouble() / 1000); // 1 maxSpeed = 1000 ms
//    if (accumulator.length > maxSpeed) {
//      accumulator.normalize();
//      accumulator.scale(maxSpeed.toDouble());
//    }

    velocity = accumulator;
    position = position + velocity * dt;
    //position.setValues(position.x.toDouble() + 0.01, position.y.toDouble() + 0.01);
  }


  void drawLineTo(html.CanvasRenderingContext2D ctx, num x, num y) {
    ctx.lineWidth = 0.02;
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(x, y);
    ctx.stroke();
  }

  void draw(html.CanvasRenderingContext2D ctx, num dt) {
    ctx.save();
    ctx.translate(position.x, position.y);
    num desiredAngle = 0;

    if (target != null) {
      temp = target.position - position;
      temp.normalize();
      desiredAngle = math.atan2(temp.x, -temp.y);

      num x1 = math.cos(angle);
      num y1 = math.sin(angle);
      num x2 = math.cos(desiredAngle);
      num y2 = math.sin(desiredAngle);

      num crossScalar = math.asin(x1 * y2 - x2 * y1);
      if (crossScalar >= 0) {
        angle += 5.0 * math.PI / 180.0;
      } else {
        angle -= 5.0 * math.PI / 180.0;
      }
    }
    else {
      // Rotate to velocity (but velocity might be zero)
      //desiredAngle = math.atan2(velocity.x * (1.0/dt), -velocity.y * (1.0 / dt));
    }

    ctx.rotate(angle);
    ctx.drawImageToRect(imageElement, new html.Rectangle(-(radius/2), -(radius/2), radius, radius));
    ctx.restore();

    if (target != null) {
      weapon.draw(this, target, ctx, dt);
    }
  }
}