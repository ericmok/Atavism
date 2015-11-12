part of AtavismEngine;


enum AttackState {
  READY, // State for outside handling
  SWINGING,
  CASTING, // State for outside handling
  COOLDOWN
}

enum AttackType {
  NORMAL,
  CHEMICAL,
  PIERCING,
  MAGICAL,
  SIEGE
}

enum ArmorType {
  LIGHT,
  NORMAL,
  HEAVY,
  BUILDING
}

class Weapon {
  AttackType attackType = AttackType.NORMAL;
  AttackState attackState = AttackState.READY;
  num attackSwingTime = 1;
  num attackCooldownTime = 1;
  num attackRange = 1;

  num attackDamage = 1;
  num attackProgress = 0;

  BattleUnit owner = null;
  BattleUnit target = null;

  Weapon() {//, this.attackType, this.attackDamage, this.attackRange, this.attackSwingTime, this.attackCooldownTime}) {
    this.attackState = AttackState.READY;
    this.attackProgress = 0;
  }

  bool isAwaitingOnReady() {
    return this.attackState == AttackState.READY;
  }

  bool isAwaitingOnCasting() {
    return this.attackState == AttackState.CASTING;
  }

  void startSwing() {
    this.attackState = AttackState.SWINGING;
    this.attackProgress = 0;
  }

  void startCooldown() {
    this.attackState = AttackState.COOLDOWN;
    this.attackProgress = 0;
  }

  void update(num dt) {
    if (this.attackState == AttackState.SWINGING) {
      this.attackProgress += dt;
      if (attackProgress > attackSwingTime) {
        this.attackState = AttackState.CASTING;
        this.attackProgress = 0;
      }
    }
    if (this.attackState == AttackState.COOLDOWN) {
      this.attackProgress += dt;
      if (attackProgress > attackCooldownTime) {
        this.attackState = AttackState.READY;
        this.attackProgress = 0;
      }
    }
  }

  void draw(BattleUnit user, BattleUnit target, html.CanvasRenderingContext2D ctx, num dt) {
    ctx.save();
    ctx.fillStyle = '#FF0000';
    Vector2 temp = target.position - user.position;
    Vector2 normalizedTemp = temp.normalized();
    ctx.fillRect(0.5 * temp.x + user.position.x, 0.5 * temp.y + user.position.y, 1, 1);
    ctx.restore();
  }
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


Weapon NORMAL_WEAPON = new Weapon();

class BattleUnit {

  Vector2 temp = new Vector2.zero();

  Vector2 position = new Vector2.zero();
  Vector2 velocity = new Vector2.zero();
  //Vector2 orientation = new Vector2(1.0, 0.0);
  num angle = 0;
  num radius = 1;

  Vector2 separationForce = new Vector2.zero();

  num maxSpeed = 1;
  num turningAngle = 1;

  Weapon weapon = new Weapon(); //NORMAL_WEAPON; // = new Weapon(this); //, attackType: AttackType.NORMAL, attackDamage: 1, attackRange: 1, attackSwingTime: 1, attackCooldownTime: 1);
  Armor armor = new Armor();

  num hp = 1;

  num targetAcquisitionRange = 10;
  BattleUnit target = null;

  Vector2 destination = new Vector2.zero();

  Goal action = Goal.IDLE;

  html.ImageElement imageElement = TextureLoader.ZUG_IMAGE;

  BattleUnit() {
  }

  void attack(BattleUnit other) {
  }

  void hurt(Weapon weapon) {
    switch(weapon.attackType) {
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

    this.hp -= weapon.attackDamage;
  }

  void onAttackCast() {
  }

  void onAttackFail() {
  }

  bool isAlive() {
    return hp > 0;
  }

  void update(BattleSystem battleSystem, num dt) {

    // Momentum
    velocity.scale(0.1);
    separationForce.scale(0.1);

    battleSystem.battleUnits.forEach((BattleUnit battleUnit) {
      if (this != battleUnit) {
        temp = position - battleUnit.position;
        num distanceScale = 0.001 / (temp.x * temp.x + temp.y * temp.y);
        temp.normalize();
        temp.scale(distanceScale);
        temp.copyInto(separationForce);
      }
    });

    velocity += temp;

    if (action == Goal.IDLE) {

      // Then look for a target
      battleSystem.battleUnits.forEach((BattleUnit battleUnit) {
        if (this == battleUnit || !battleUnit.isAlive()) {
          return;
        }

        if (position.distanceTo(battleUnit.position) < targetAcquisitionRange) {
          target = battleUnit;
          action = Goal.KILL_TARGET;
        }
      });
    }

    if (action == Goal.KILL_TARGET) {
      // Test if given the goal, the target is non-null / alive

      weapon.update(dt);

      if (target == null || !target.isAlive()) {
        action = Goal.IDLE;
        return;
      }

      if (weapon.isAwaitingOnReady()) {
        if (position.distanceTo(target.position) > weapon.attackRange * 0.9) {
          // TODO: Memory
          temp = target.position - position;
          temp.normalize();
          temp.scale(dt);
          velocity += temp;
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
    ctx.drawImageToRect(imageElement, new html.Rectangle<double>(-(radius/2), -(radius/2), radius, radius));
    ctx.restore();

    if (target != null) {
      weapon.draw(this, target, ctx, dt);
    }
  }
}