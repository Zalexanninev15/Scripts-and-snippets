/// There are three modes can be used.

// Mode 1: Percentage mode
ProgressBar progressBar = new ProgressBar();
progressBar.Show();
progressBar.Update(0.01);

// Mode 2: Item count mode
ProgressBar progressBar = new ProgressBar(100);
progressBar.Show();
progressBar.Update(1);

// Mode 3: Increase mode
ProgressBar progressBar = new ProgressBar(100);
progressBar.Show();
progressBar.UpdateOnce();