class MobileMenu extends React.Component{

    onClick(e){
        var isOpen = true;
        if(this.state.menuOpen)
            isOpen = false;

        this.setState({
            menuOpen: isOpen
        });
    };

   onClickFunc = this.onClick.bind(this);

    constructor() {
        super();

        this.state = {
            menuOpen: false
        };
        return this;
    }

    render() {
        return React.createElement(AppBar, {
            position: "static",
            className: "header_bar",
            id: "mobile_app_bar"
        }, React.createElement("img", {
            src: "resources/images/VolteFaceBeautyLogo.svg",
            alt: "logo",
            className: "title_image"
        }), React.createElement(Drawer, {
            variant: "persistent",
            anchor: "right",
            open: this.state.menuOpen,
            className: "menu_drawer",
            classes: {
                paper: "menu_paper"
            }
        },React.createElement(MenuButtons,
            {className: "drawer_button"
            }
        )), React.createElement("div", {
            className: "menu_div"
        }, React.createElement(Button, {
            id: "test_btn",
            variant: "text",
            className: "menu_icon_button",
            onClick: this.onClickFunc
        }, React.createElement("i", {
            className: "material-icons menu_icon"
        }, "menu"))));
    }
}