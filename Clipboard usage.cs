// Gets the clipboard text
GetClipboardText GetClipboard = new GetClipboardText();
string output = GetClipboard.GetText();

// Sets the clipboard text
string input = "Hello World!";
await SetClipboardText.Run(() => System.Windows.Forms.Clipboard.SetText(input));