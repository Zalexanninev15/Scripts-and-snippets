private PerformanceCounter PCounter = new PerformanceCounter();
// Your code
PCounter.Start();// Start measure
// Your code for measurements
double interval = PCounter.End(); // Result interval in seconds