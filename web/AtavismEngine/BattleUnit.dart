part of AtavismEngine;


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
  Vector2 accumulator = new Vector2.zero();

  num angle = 0;
  num radius = 1;

  num team = 0;

  Vector2 separationForce = new Vector2.zero();

  num maxSpeed = 4;
  num turningAngle = 1;

  Weapon weapon = new Weapon(NORMAL_WEAPON_DEF);
  Armor armor = new Armor();

  num hp = 1;

  num targetAcquisitionRange = 30;
  BattleUnit target = null;
  num minimumTargetDistance = 10000;

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

  bool acquireTarget(BattleSystem battleSystem, num dt) {
    minimumTargetDistance = 10000;

    // Then look for a target
    for (num i = 0; i < battleSystem.battleUnits.length; i++) {
      BattleUnit battleUnit = battleSystem.battleUnits[i];

      if (this == battleUnit || !battleUnit.isAlive() || this.team == battleUnit.team) {
        continue;
      }

      num distance = position.distanceTo(battleUnit.position);

      if (distance < targetAcquisitionRange) {

        if (distance < minimumTargetDistance) {
          target = battleUnit;
          action = Goal.KILL_TARGET;
          minimumTargetDistance = distance;
        }
      }
    }

    return true;
  }

  void update(BattleSystem battleSystem, num dt) {

    // Momentum
    velocity.scale(0.1);
    separationForce.scale(0.1);

    battleSystem.battleUnits.forEach((BattleUnit battleUnit) {
      if (this != battleUnit && this.position.distanceTo(battleUnit.position) < 1.5) {
        temp = position - battleUnit.position;
        num distanceScale = 0.05 / (temp.x * temp.x + temp.y * temp.y);
        temp.normalize();
        temp.scale(distanceScale);
        temp.copyInto(separationForce);
      }
    });

    accumulator += temp;

    if (action == Goal.IDLE) {
      acquireTarget(battleSystem, dt);
    }

    if (action == Goal.KILL_TARGET) {
      // Test if given the goal, the target is non-null / alive

      weapon.update(dt);

      if (target == null || !target.isAlive()) {
        action = Goal.IDLE;
        return;
      }

      if (weapon.isAwaitingOnReady()) {
        if (position.distanceTo(target.position) > weapon.weaponDef.attackRange * 0.9) {
          // TODO: Memory
          temp = target.position - position;
          temp.normalize();
          temp.scale(dt);
          accumulator += temp;
        } else {
          weapon.startSwing();
        }
      }

      if (weapon.isAwaitingOnCasting()) {
        target.hurt(weapon);

        if (!target.isAlive()) {
          battleSystem.queueRemoveUnit(target);
          target = null;
          action = Goal.IDLE;
        }

        weapon.startCooldown();
      }
    }

    accumulator.normalize();
    accumulator.scale(maxSpeed.toDouble() / 1000); // 1 maxSpeed = 1000 ms

    velocity += accumulator;
    position = position + velocity;
    //position.setValues(position.x.toDouble() + 0.01, position.y.toDouble() + 0.01);
  }


  void draw(html.CanvasRenderingContext2D ctx, num dt) {
    ctx.save();
    ctx.translate(position.x, position.y);
    num desiredAngle = 0;

    // TODO: Take cross product, use the sign to add/sub angle
    if (target != null) {
      temp = target.position - position;
      temp.normalize();
      //desiredAngle = math.atan2(-temp.y, temp.x) + math.PI;
      desiredAngle = math.atan2(temp.x, -temp.y);
    }
    else {
      //desiredAngle = math.atan2(-velocity.normalized().y, velocity.normalized().x) - math.PI;
      desiredAngle = math.atan2(velocity.normalized().x, -velocity.normalized().y);
    }

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

    //angle = angle + 0.1 * (desiredAngle - angle);
    //angle = desiredAngle;
    //ctx.rotate(angle + 90);
    ctx.rotate(angle);
    ctx.drawImageToRect(imageElement, new html.Rectangle(-(radius/2), -(radius/2), radius, radius));
    ctx.restore();

    if (target != null) {
      weapon.draw(this, target, ctx, dt);
    }
  }
}