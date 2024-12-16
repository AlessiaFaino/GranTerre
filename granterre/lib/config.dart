library my_app.globals;

bool simulationConfezionatriceOn = false;
bool simulationIncartonatriceOn = false;
int secondsIntervalConfezionatrice = 3; //TODO: put 60
int secondsIntervalIncartonatrice = 2; //TODO: put 60
int indexConfezionatrice = 0;
int indexIncartonatrice = 0;


final Map<int, String> machines = {
  0: "Confezionatrice",
  1: "Incartonatrice",
};