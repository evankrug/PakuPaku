class MovingEntity {
   constructor(id) {
       this.id = id;
       this.element = document.getElementById(id);

       // if no HTML elements with this id, throw error
       if(!this.element)
           throw "Invalid Moving Entity Id: " + this.id;
   }

   static xPropName = '--x_coord';
   static yPropName = '--y_cord';
   static directions = ["up", "down", "left", "right"];

   setX = newX => util.setPropertyValue(this.element, this.constructor.xPropName, newX);

   setY = newY => util.setPropertyValue(this.element, this.constructor.yPropName, newY);

   changeDirection = direction => this.element.setAttribute(this.constructor.attrNames.direction, direction);

   setAttr = (attrName, value) => util.setAttributeValue(this.element, attrName, value);

}