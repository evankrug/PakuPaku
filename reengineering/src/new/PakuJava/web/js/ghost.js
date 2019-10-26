class Ghost extends MovingEntity {
    constructor(id) {
        super(id);
    }

    static attrNames = {
        direction: 'direction',
        state: 'state'
    };

    static states = ["normal", "eaten", "scared", "scaredExpiring"];

    changeStates = state => this.setAttr(this.constructor.attrNames.state, state);
}