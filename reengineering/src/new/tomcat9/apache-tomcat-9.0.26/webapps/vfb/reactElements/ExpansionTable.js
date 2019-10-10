class ExpansionTable extends React.Component {
    //props: Heading/Title[props.title], data source[props.data], desired data object[props.dataObj]
    constructor(props) {
        super();
        this.props = props;
        this.state = {
            showDialog: false,
            isExpanded: true,
            validEmail: true,
            emailValue: "",
            cellValue: "",
            validPhoneNum: true
        };
        this.toggleDialog = this.toggleDialogFunc.bind(this);
        this.expandedChangeFunc = this.expandedChange.bind(this);
        this.checkEmail = this.checkEmailFunc.bind(this);
        this.updateCell = this.updateCellFunc.bind(this);
    };

    expandedChange() {
        var expanded = this.state.isExpanded;
        expanded = !expanded;
        this.setState({isExpanded: expanded});
    }

    toggleDialogFunc() {
        var showing = this.state.showDialog;
        showing = !showing;
        this.setState({
            showDialog: showing,
            emailValue: "",
            cellValue: "",
            validPhoneNum: true,
            validEmail: true
        });
    };

    checkEmailFunc(email) {
        this.setState({
            validEmail: isValidEmail(email),
            emailValue: email
        });
    };

    updateCellFunc(number) {
        this.setState({
            cellValue: formatPhoneNumber(number),
            validPhoneNum: isValidPhoneNumber(number)
        });
    };

    render() {
        return (
            <ExpansionPanel className="expansion_paper"
                            expanded={this.state.isExpanded}
                            onChange={this.expandedChangeFunc}>
                <ExpansionPanelSummary expandIcon={<i className="material-icons">keyboard_arrow_down</i>}>
                    <div className="expansion_heading">{this.props.title}</div>
                </ExpansionPanelSummary>
                <ExpansionPanelDetails className="expansion_body">
                    <Table className="tbl">
                        <TableHead className="tbl_hd">
                            <TableRow className="tbl_row">
                                <TableCell className="tbl_cell tbl_header_cell">Service</TableCell>
                                <TableCell className="tbl_cell tbl_header_cell">Average Price</TableCell>
                                <TableCell className="tbl_cell tbl_header_cell">Average Time</TableCell>
                                <TableCell className="tbl_cell tbl_header_cell"/>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {this.props.dataObj.map((data) => {
                                return (
                                    <TableRow className="tbl_row" key={data.RowNum}>
                                        <TableCell className="tbl_cell" >
                                            {data.Service}
                                        </TableCell>
                                        <TableCell className="tbl_cell tbl_data_cell"
                                                   align="right">
                                            {formatPrice(data.Price)}
                                        </TableCell>
                                        <TableCell className="tbl_cell tbl_data_cell"
                                                   align="right">
                                            {data.Time}
                                        </TableCell>
                                        <TableCell className="tbl_cell tbl_data_cell">
                                            <Button variant="outlined"
                                                    className="booking_button"
                                                    onClick={this.toggleDialog}>
                                                Book
                                            </Button>
                                        </TableCell>
                                    </TableRow>
                                );
                            })}
                        </TableBody>
                    </Table>
                </ExpansionPanelDetails>
                <Dialog open={this.state.showDialog}
                        onClose={this.toggleDialog}>
                    <DialogTitle>Book Appointment</DialogTitle>
                    <DialogContent className="expansion_dialog_content">
                        <DayPicker></DayPicker>
                        <TextField
                            required
                            id="appt_email"
                            label="Email"
                            placeholder="example@voltefacebeauty.com"
                            className="appt_email"
                            margin="normal"
                            onChange={e => this.checkEmail(e.target.value)}
                            error={!this.state.validEmail}
                            value={this.state.emailValue}
                        />
                        <TextField
                            id="appt_phone"
                            label="Cell Phone"
                            placeholder="(555)-555-5555"
                            className="appt_phone"
                            margin="normal"
                            onChange={e => this.updateCell(e.target.value)}
                            value={this.state.cellValue}
                            error={!this.state.validPhoneNum}
                        />
                    </DialogContent>
                </Dialog>
            </ExpansionPanel>
        );
    };
}