class Paku extends MovingEntity {
    constructor() {
        super('paku');
    }

    static attrNames = {
        direction: 'direction',
        status: 'status'
    };

    static statuses = ["go, stop"];

    changeStatus = status => this.setAttr(this.constructor.attrNames.status, status);
}