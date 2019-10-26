class Util {
    // Class variables
    rootStyle;
    aspectRatio = {
        height: 2, // 100
        width: 3.2 // 160
    };
    // This method updates adjusts the height/width relationship to allow the screen to fit in windows
    // where the height > calculated width
    heightAdjust = () => {
        let height =window.innerHeight;
        let width = window.innerWidth;
        if(height > (width * this.aspectRatio.height / this.aspectRatio.width))
            this.setPropertyValue("--screen_height", (width / this.aspectRatio.width * this.aspectRatio.height)+ "px");
    };

    // Sets the value of a given CSS property/value. Throws an exception if no such property exists.
    setPropertyValue = (element, propertyName, newValue) => {
        if(element.style.getPropertyValue(propertyName))
            element.style.setProperty(propertyName, newValue);
        else
            throw "Exception: Property " + propertyName + " does not exist";
    };

    // Gets the :root pseudo element from 'globals.css'. This element can then be used
    // to update CSS variables using javascript.
    getRootCssElement = () => this.rootStyle =  this.getCssElement("global.css", ":root");

    // Initializes the game window
    initGame = () => {
        this.getRootCssElement();
        this.heightAdjust();
    };

    getCssElement= (sheetName, elementName) => {
        let el;

        for(let sheet of document.styleSheets)
            if(sheet.href.includes(sheetName))
                for(let rule of sheet.cssRules)
                    if(rule.selectorText === elementName)
                        el = rule;
        return el;
    };

    setAttributeValue = (element, attrName, value) => element.setAttribute(attrName, value);
}

// Main Method
let util = new Util();
util.initGame();

//document.getElementById('paku').getPropertyValue('--paku_space_x');