import sys
from functools import partial

from PySide6.QtWidgets import (
    QApplication,
    QGridLayout,
    QPushButton,
    QStyle,
    QWidget,
    QLabel,
    QVBoxLayout,
    QHBoxLayout,
    QComboBox,
    QStyleFactory,
)
from PySide6.QtGui import QGuiApplication


class Window(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("PySide6 [Standard Icons + Theme Changer]")

        main_layout = QVBoxLayout(self)

        # --- Theme Changer ---
        theme_layout = QHBoxLayout()
        theme_label = QLabel("Select Theme:")
        self.theme_combo = QComboBox()

        # Add available styles to the combo box
        available_styles = QStyleFactory.keys()
        self.theme_combo.addItems(available_styles)

        # Set a default style if available
        if "Fusion" in available_styles:
            self.theme_combo.setCurrentText("Fusion")
            QApplication.setStyle(QStyleFactory.create("Fusion"))

        self.theme_combo.currentTextChanged.connect(self.change_theme)

        theme_layout.addWidget(theme_label)
        theme_layout.addWidget(self.theme_combo)
        main_layout.addLayout(theme_layout)
        # --------------------

        self.info_label = QLabel("Click on any button to copy its icon name to the clipboard.")
        main_layout.addWidget(self.info_label)

        grid_layout = QGridLayout()

        icons = sorted(
            [attr for attr in dir(QStyle.StandardPixmap) if attr.startswith("SP_")]
        )

        self.buttons = []  # Store buttons to update their icons
        for n, name in enumerate(icons):
            btn = QPushButton(name)
            self.update_icon(btn, name)  # Set the initial icon

            btn.clicked.connect(partial(self.copy_icon_name, name))

            grid_layout.addWidget(btn, n // 4, n % 4)
            self.buttons.append((btn, name))

        container = QWidget()
        container.setLayout(grid_layout)
        main_layout.addWidget(container)

    def update_icon(self, button, icon_name):
        """Sets the icon for a button based on the current style."""
        pixmapi = getattr(QStyle.StandardPixmap, icon_name)
        icon = self.style().standardIcon(pixmapi)
        button.setIcon(icon)

    def change_theme(self, theme_name):
        """
        Changes the application's stylesheet and updates all icons.
        """
        style = QStyleFactory.create(theme_name)
        if style:
            QApplication.setStyle(style)
            # Update icons for all buttons as they can change with the theme
            for btn, name in self.buttons:
                self.update_icon(btn, name)
            self.info_label.setText(f"Theme changed to '{theme_name}'.")
        else:
            self.info_label.setText(f"Could not create style '{theme_name}'.")

    def copy_icon_name(self, icon_name):
        """
        Copies the provided icon name to the system clipboard.
        """
        clipboard = QGuiApplication.clipboard()
        clipboard.setText(icon_name)
        self.info_label.setText(f"Copied '{icon_name}' to clipboard.")
        print(f"Copied '{icon_name}' to clipboard.")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    w = Window()
    w.show()
    sys.exit(app.exec())