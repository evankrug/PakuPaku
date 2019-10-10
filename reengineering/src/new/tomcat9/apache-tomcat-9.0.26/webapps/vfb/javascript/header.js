var titleBar = function(){
    return(
        <AppBar position="static"
            className="header_bar">
                <img src="../resources/images/VolteFaceBeautyLogo.svg" alt="logo" className="title_image"/>
            <Toolbar className="header_button_container">
                <MenuButtons className="header_button"/>
            </Toolbar>
        </AppBar>
    );
};

var renderObject = titleBar();
if(isMobile())
    renderObject = React.createElement(MobileMenu, null, null);

ReactDOM.render(
    renderObject,
    document.getElementById("header")
);


