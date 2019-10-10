class AppointmentStepper extends React.Component {

    nextStep(){
        var curStep = this.state.currentStep;
        if(curStep < this.state.maxSteps)
            curStep++;
        else
            curStep = 0;
        this.setState({
            currentStep: curStep
        });
    };

    constructor(){
        super();

        this.state = {
            currentStep: 0,
            maxSteps: 3
        };
        return this;
    };

    render() {
        return (
            <div className="stepper_vertical">
                    <Stepper orientation="vertical" activeStep ={this.state.currentStep}>
                        <Step>
                            <StepLabel>Select<br/>a Date</StepLabel>
                        </Step>
                        <Step>
                            <StepLabel>Select<br/>a Time</StepLabel>
                        </Step>
                        <Step>
                            <StepLabel>Contact<br/>Information</StepLabel>
                        </Step>
                        <Step>
                            <StepLabel>Confirm<br/>Information</StepLabel>
                        </Step>
                    </Stepper>
                <div className="stepper_horizontal">
                    <Button variant="contained" className={"appointment_stepper_buttons_paper"} onClick={this.nextStep.bind(this)}>Next</Button>
                </div>
            </div>
        );
    }
}

