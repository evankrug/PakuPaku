class MenuButtons extends React.Component {

    props;

    constructor(props)
    {
        super();
        this.props = props;
    }

    render(){
      return React.createElement("div", {},
                React.createElement(Button, {
                    className: this.props.className,
                    onClick: () => {navigate("home")}
                }, "Home"),
                React.createElement(Button, {
                    className: this.props.className,
                    onClick: () => {navigate("hair")}
                  }, "Hair"),
                React.createElement(Button, {
                    className: this.props.className,
                    onClick: () => {navigate("makeup")}
                }, "Makeup"),
                React.createElement (Button, {
                    className: this.props.className,
                    onClick: () => {navigate("appointment"); renderCalendar()}
                }, "Appointment"),
                React.createElement(Button, {
                    className: this.props.className,
                    onClick: () => {navigate("store")}
                }, "Store"),
                React.createElement(Button, {
                    className: this.props.className,
                    onClick: () => {navigate("about")}
                }, "About"),
                React.createElement(Button, {
                    className: this.props.className,
                    onClick: () => {navigate("login")}
                }, "Login")
          );
      };
}