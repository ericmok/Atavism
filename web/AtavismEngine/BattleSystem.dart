part of AtavismEngine;


class BattleSystem {

  AtavismEngine atavismEngine;
  List<BattleUnit> battleUnits = new List();
  List<BattleUnit> battleUnitsToAdd = new List();
  List<BattleUnit> battleUnitsToRemove = new List();

  BattleSystem(this.atavismEngine) {
  }

  void queueAddUnit(BattleUnit battleUnit) {
    battleUnitsToAdd.add(battleUnit);
  }

  void queueRemoveUnit(BattleUnit battleUnit) {
    battleUnitsToRemove.add(battleUnit);
  }

  void flushQueues() {
    battleUnits.removeWhere((BattleUnit test) {
      return battleUnitsToRemove.contains(test);
    });
    battleUnitsToRemove.clear();

    battleUnits.addAll(battleUnitsToAdd);
    battleUnitsToAdd.clear();
  }

  void update(num dt) {
    flushQueues();

    battleUnits.forEach((BattleUnit battleUnit) {
      battleUnit.update(this, dt);
      battleUnit.draw(atavismEngine.ctx, dt);
    });
  }
}