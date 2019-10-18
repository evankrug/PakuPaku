class Util {
    // Class variables
    rootStyle;
    aspectRatio = {
        height: 2,
        width: 3.2
    };
    // This method updates the
    heightAdjust = () => {
        let height =window.innerHeight;
        let width = window.innerWidth;
        if(height > width)
            this.setPropertyValue("--screen_height", (width / this.aspectRatio.width * this.aspectRatio.height)+ "px");
    };

    // Sets the value of a given CSS property/value. Throws an exception if no such property exists.
    setPropertyValue = (propertyName, newValue) => {
        if(this.rootStyle.style.getPropertyValue(propertyName))
            this.rootStyle.style.setProperty(propertyName, newValue);
        else
            throw "Exception: Property " + propertyName + " does not exist";
    };

    // Gets the :root pseudo element from 'globals.css'. This element can then be used
    // to update CSS variables using javascript.
    getRootCssElement = () => {
        for(let sheet of document.styleSheets)
            if(sheet.href.includes("global.css"))
                for(let rule of sheet.cssRules)
                    if(rule.selectorText === ":root")
                        this.rootStyle = rule;
    };

    // Initializes the game window
    initGame = () => {
        this.getRootCssElement();
        this.heightAdjust();
    }
}


// Main Method
let util = new Util();
util.initGame();