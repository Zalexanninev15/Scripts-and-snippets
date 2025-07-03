# Examples:
# 1. Show-ModernMessageBox -Title "Task Complete" -Message "The data has been successfully processed." -Icon Information

# 2. Show-ModernMessageBox -Title "Error" -Message "Failed to connect to the remote server. Please check your network connection and credentials." -Icon Error

# 3. $confirmation = Show-ModernMessageBox -Title "Confirm Action" -Message "Are you sure you want to format the drive? This action cannot be undone." -Buttons YesNo -Icon Warning
# if ($confirmation -eq "Yes") {
#    Write-Host "User chose YES. Proceeding with format..." -ForegroundColor Yellow
#    # Add your format command here
# }
# else {
#    Write-Host "User chose NO or closed the dialog. Action cancelled." -ForegroundColor Green
# }

function Show-ModernMessageBox {
    <#
    .SYNOPSIS
        Displays a customizable, modern-style message box with a dark theme.
    .DESCRIPTION
        This function uses WPF and XAML to create a message box that mimics the look and feel of modern Windows 10/11 UI elements.
        It is a modal dialog, meaning the script will pause until the user clicks a button.
    .PARAMETER Title
        The text to display in the title bar of the message box.
    .PARAMETER Message
        The main message content to display in the dialog.
    .PARAMETER Buttons
        Specifies which buttons to display on the message box.
        Valid values are: 'OK', 'OKCancel', 'YesNo', 'YesNoCancel'.
    .PARAMETER Icon
        Specifies which icon to display next to the message.
        Valid values are: 'None', 'Information', 'Warning', 'Error', 'Question'.
    .EXAMPLE
        Show-ModernMessageBox -Title "Action Complete" -Message "The script has finished running successfully." -Icon Information
    .EXAMPLE
        $result = Show-ModernMessageBox -Title "Confirm Deletion" -Message "Are you sure you want to delete this file permanently?" -Buttons YesNo -Icon Warning
        if ($result -eq "Yes") { Write-Host "User confirmed deletion." }
    .OUTPUTS
        [string] The name of the button the user clicked ('OK', 'Cancel', 'Yes', 'No'). Returns $null if the window is closed.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet('OK', 'OKCancel', 'YesNo', 'YesNoCancel')]
        [string]$Buttons = 'OK',

        [ValidateSet('None', 'Information', 'Warning', 'Error', 'Question')]
        [string]$Icon = 'None'
    )

    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$Title"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        WindowStartupLocation="CenterScreen"
        SizeToContent="WidthAndHeight" MinWidth="350" MaxWidth="500"
        FontFamily="Segoe UI">

    <Window.Resources>
        <!-- Style for the main dialog buttons (e.g., OK, Yes) -->
        <Style x:Key="DialogButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="#FF0078D4"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="14" />
            <Setter Property="Padding" Value="12,8"/> <!-- CHANGE: Increased vertical padding for taller buttons -->
            <Setter Property="MinWidth" Value="90"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" CornerRadius="4" Background="{TemplateBinding Background}" BorderThickness="{TemplateBinding BorderThickness}" BorderBrush="{TemplateBinding BorderBrush}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FF1088E4"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FF005A9E"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Style for secondary buttons (e.g., Cancel) -->
        <Style x:Key="SecondaryDialogButtonStyle" TargetType="Button" BasedOn="{StaticResource DialogButtonStyle}">
            <Setter Property="Background" Value="#FF505050"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" CornerRadius="4" Background="{TemplateBinding Background}" BorderThickness="{TemplateBinding BorderThickness}" BorderBrush="{TemplateBinding BorderBrush}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FF606060"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FF404040"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Style for the 'X' close button in the title bar -->
        <Style x:Key="TitleBarButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#FF404040"/>
                </Trigger>
                <Trigger Property="IsPressed" Value="True">
                    <Setter Property="Background" Value="#FF505050"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>

    <Border BorderBrush="#444444" BorderThickness="1" CornerRadius="8" Background="#FF202020">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Border x:Name="TitleBar" Grid.Row="0" Height="40" Background="Transparent">
                <Grid>
                    <TextBlock Text="$Title" Foreground="White" FontSize="14" VerticalAlignment="Center" Margin="15,0,0,0" />
                    <Button x:Name="CloseButton" Content="" FontFamily="Segoe MDL2 Assets" 
                            Foreground="White" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Right" 
                            Width="40" Height="40" Style="{StaticResource TitleBarButtonStyle}" />
                </Grid>
            </Border>

            <Grid Grid.Row="1" Margin="20,10,20,20">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto" />
                    <ColumnDefinition Width="*" />
                </Grid.ColumnDefinitions>
                
                <TextBlock x:Name="IconTextBlock" Grid.Column="0" Text="" FontFamily="Segoe MDL2 Assets" 
                           FontSize="32" VerticalAlignment="Top" Margin="0,5,20,0" />

                <TextBlock Grid.Column="1" Text="$Message" Foreground="#DDFFFFFF" FontSize="15" TextWrapping="Wrap" VerticalAlignment="Center"/>
            </Grid>

            <Border Grid.Row="2" Background="#FF2D2D2D" CornerRadius="0,0,7,7">
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Margin="15">
                    <Button x:Name="YesButton" Content="Yes" Style="{StaticResource DialogButtonStyle}" Margin="0,0,10,0" />
                    <Button x:Name="NoButton" Content="No" Style="{StaticResource DialogButtonStyle}" Margin="0,0,10,0" />
                    <Button x:Name="OKButton" Content="OK" Style="{StaticResource DialogButtonStyle}" Margin="0,0,10,0" />
                    <Button x:Name="CancelButton" Content="Cancel" Style="{StaticResource SecondaryDialogButtonStyle}" />
                </StackPanel>
            </Border>
        </Grid>
    </Border>
</Window>
"@

    $xmlReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
    try {
        $window = [System.Windows.Markup.XamlReader]::Load($xmlReader)
    }
    catch {
        Write-Error "Error parsing XAML: $($_.Exception.Message)"
        return
    }

    $dialogResult = $null
    $controls = @{}
    'OKButton', 'CancelButton', 'YesButton', 'NoButton', 'CloseButton', 'IconTextBlock', 'TitleBar' | ForEach-Object {
        $controls[$_] = $window.FindName($_)
    }

    $iconMap = @{
        Information = @{ Char = ''; Color = '#0078D4' }
        Warning     = @{ Char = ''; Color = '#F1C40F' }
        Error       = @{ Char = ''; Color = '#C50F1F' }
        Question    = @{ Char = ''; Color = '#0078D4' }
    }

    if ($Icon -ne 'None') {
        $controls.IconTextBlock.Text = [System.Net.WebUtility]::HtmlDecode($iconMap[$Icon].Char)
        $controls.IconTextBlock.Foreground = $iconMap[$Icon].Color
    } else {
        $controls.IconTextBlock.Visibility = 'Collapsed'
    }

    $controls.Values | Where-Object { $_ -is [System.Windows.Controls.Button] } | ForEach-Object { $_.Visibility = 'Collapsed' }
    $controls.CloseButton.Visibility = 'Visible'

    switch ($Buttons) {
        'OK'          { $controls.OKButton.Visibility = 'Visible' }
        'OKCancel'    { $controls.OKButton.Visibility = 'Visible'; $controls.CancelButton.Visibility = 'Visible' }
        'YesNo'       { $controls.YesButton.Visibility = 'Visible'; $controls.NoButton.Visibility = 'Visible' }
        'YesNoCancel' { $controls.YesButton.Visibility = 'Visible'; $controls.NoButton.Visibility = 'Visible'; $controls.CancelButton.Visibility = 'Visible' }
    }

    $controls.OKButton.add_Click({ $script:dialogResult = 'OK'; $window.Close() })
    $controls.CancelButton.add_Click({ $script:dialogResult = 'Cancel'; $window.Close() })
    $controls.YesButton.add_Click({ $script:dialogResult = 'Yes'; $window.Close() })
    $controls.NoButton.add_Click({ $script:dialogResult = 'No'; $window.Close() })
    $controls.CloseButton.add_Click({ $script:dialogResult = $null; $window.Close() })
    $controls.TitleBar.add_MouseDown({ $window.DragMove() })
    $window.add_KeyDown({
        param($sender, $e)
        if ($e.Key -eq 'Escape') { 
            if ($controls.CancelButton.IsVisible) { $script:dialogResult = 'Cancel' } 
            else { $script:dialogResult = $null }
            $window.Close() 
        }
    })

    $window.ShowDialog() | Out-Null
    return $script:dialogResult
}
