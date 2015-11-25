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

class WeaponDef {
  AttackType attackType = AttackType.NORMAL;
  num attackSwingTime = 0.5;
  num attackCooldownTime = 0.5;
  num attackRange = 1;
  num attackDamage = 1;

  WeaponAnimation createWeaponAnimation() {
    return new NormalWeaponAnimation();
  }
}

abstract class WeaponAnimation {
  void draw(DisplayObjectContainer container, BattleUnit attacker, num dt);
}

class NormalWeaponAnimation implements WeaponAnimation{
  Sprite sprite = new Sprite.fromImage(TextureLoader.TEST);
  bool spriteAdded = false;

  NormalWeaponAnimation();

  void draw(DisplayObjectContainer container, BattleUnit attacker, num dt) {
    BattleUnit target = attacker.target;

    if (attacker.weapon.attackState == AttackState.SWINGING && target != null && target.isAlive()) {
      Vector2 temp = target.position - attacker.position;
      Vector2 normalizedTemp = temp.normalized();

      if (!spriteAdded) {
        container.addChild(sprite);
        spriteAdded = true;
      }

      sprite.width = 0.2;
      sprite.height = 0.2;
      sprite.position.x = (attacker.weapon.attackProgress / attacker.weapon.weaponDef.attackSwingTime) * temp.x + attacker.position.x;
      sprite.position.y = (attacker.weapon.attackProgress / attacker.weapon.weaponDef.attackSwingTime) * temp.y + attacker.position.y;
    } else {
      if (spriteAdded) {
        container.removeChild(sprite);
        spriteAdded = false;
      }
    }
  }
}

var NORMAL_WEAPON_DEF = new WeaponDef();
var RIFLE_WEAPON_DEF = new WeaponDef()
    ..attackRange = 3;

class Weapon {
  WeaponDef weaponDef = null;
  WeaponAnimation weaponAnimation;

  AttackState attackState = AttackState.READY;
  num attackProgress = 0;

  BattleUnit owner = null;
  BattleUnit target = null;

  Sprite projectile = new Sprite.fromImage(TextureLoader.TEST);

  Weapon(WeaponDef weaponDef, this.owner) {//, this.attackType, this.attackDamage, this.attackRange, this.attackSwingTime, this.attackCooldownTime}) {
    this.weaponDef = weaponDef;
    this.weaponAnimation = weaponDef.createWeaponAnimation();

//
    this.attackState = AttackState.READY;
    this.attackProgress = 0;
  }

  bool isAwaitingOnReady() {
    return this.attackState == AttackState.READY;
  }

  bool isSwinging() {
    return this.attackState == AttackState.SWINGING;
  }

  bool isAwaitingOnCasting() {
    return this.attackState == AttackState.CASTING;
  }

  bool isCooldown() {
    return this.attackState == AttackState.COOLDOWN;
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
      if (attackProgress > weaponDef.attackSwingTime) {
        this.attackState = AttackState.CASTING;
        this.attackProgress = 0;
      }
    }
    if (this.attackState == AttackState.COOLDOWN) {
      this.attackProgress += dt;
      if (attackProgress > weaponDef.attackCooldownTime) {
        this.attackState = AttackState.READY;
        this.attackProgress = 0;
      }
    }
  }


  void draw(DisplayObjectContainer container, num dt) {
    this.weaponAnimation.draw(container, owner, dt);
  }

  // void draw(BattleUnit user, BattleUnit target, html.CanvasRenderingContext2D ctx, num dt) {
  //   weaponDef.draw(user, target, ctx, dt);
  // }
}
