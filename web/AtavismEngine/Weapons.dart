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

class WeaponDef {
  AttackType attackType = AttackType.NORMAL;
  num attackSwingTime = 0.5;
  num attackCooldownTime = 0.5;
  num attackRange = 1;
  num attackDamage = 1;

  void draw(BattleUnit user, BattleUnit target, html.CanvasRenderingContext2D ctx, num dt) {
    if (user.weapon.attackState == AttackState.SWINGING && user.target != null && user.target.isAlive()) {
      ctx.save();
      Vector2 temp = target.position - user.position;
      Vector2 normalizedTemp = temp.normalized();
      ctx.fillStyle = 'rgba(30, 30, 30, 30)';
      ctx.fillRect(
          (user.weapon.attackProgress / this.attackSwingTime) * temp.x +
              user.position.x,
          (user.weapon.attackProgress / this.attackSwingTime) * temp.y +
              user.position.y, 0.1, 0.1);
      ctx.restore();
    }
  }
}

var NORMAL_WEAPON_DEF = new WeaponDef();
var RIFLE_WEAPON_DEF = new WeaponDef()
    ..attackRange = 3;

class Weapon {
  WeaponDef weaponDef = null;

  AttackState attackState = AttackState.READY;
  num attackProgress = 0;

  BattleUnit owner = null;
  BattleUnit target = null;

  Weapon(WeaponDef weaponDef) {//, this.attackType, this.attackDamage, this.attackRange, this.attackSwingTime, this.attackCooldownTime}) {
    this.weaponDef = weaponDef;
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

  void draw(BattleUnit user, BattleUnit target, html.CanvasRenderingContext2D ctx, num dt) {
    weaponDef.draw(user, target, ctx, dt);
  }
}
