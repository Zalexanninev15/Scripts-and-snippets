/* Although the method works, it would be better to check the installed versions 
of .NET Framework in this article (there is a code to determine the version in C#):
https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
*/

private static bool IsNetFramework45Installed() {
      Type type;      
      try {
        type = TryGetDefaultDllImportSearchPathsAttributeType();
      } catch (TypeLoadException) {
        MessageBox.Show(
          "This application requires the .NET Framework 4.5 or a later version.\n" +
          "Please install the latest .NET Framework. For more information, see\n\n" +
          "https://dotnet.microsoft.com/download/dotnet-framework",
          "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return type != null;
    }

    [MethodImpl(MethodImplOptions.NoInlining)]
    private static Type TryGetDefaultDllImportSearchPathsAttributeType() {
      return typeof(DefaultDllImportSearchPathsAttribute);
    }