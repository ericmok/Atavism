part of AtavismEngine;


class BattleSystem {

  AtavismEngine atavismEngine;
  List<BattleUnit> battleUnits = new List();
  List<BattleUnit> battleUnitsToAdd = new List();
  List<BattleUnit> battleUnitsToRemove = new List();

  Player player0 = new Player();
  Player player1 = new Player();

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
    battleUnitsToRemove.forEach((BattleUnit battleUnit) {
      switch (battleUnit.team) {
        case 0:
          player0.units.remove(battleUnit);
          break;
        case 1:
          player1.units.remove(battleUnit);
          break;
      }
    });
    battleUnitsToRemove.clear();

    battleUnits.addAll(battleUnitsToAdd);
    battleUnitsToAdd.forEach((BattleUnit battleUnit) {
      switch (battleUnit.team) {
        case 0:
          player0.units.add(battleUnit);
          break;
        case 1:
          player1.units.add(battleUnit);
          break;
      }
    });
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