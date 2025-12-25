use ratatui::{
    layout::{Alignment, Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, List, ListItem, Paragraph},
    Frame,
};

#[derive(Debug, Clone)]
pub struct MenuItem {
    pub id: usize,
    pub title: String,
    pub description: String,
    pub completed: bool,
}

pub struct MenuState {
    pub items: Vec<MenuItem>,
    pub selected: usize,
}

impl MenuState {
    pub fn new() -> Self {
        Self {
            items: vec![
                MenuItem {
                    id: 1,
                    title: "Full Installation".to_string(),
                    description: "Run all installation steps".to_string(),
                    completed: false,
                },
                MenuItem {
                    id: 2,
                    title: "Install Core Packages".to_string(),
                    description: "Install hyprland, waybar, warp-terminal, etc.".to_string(),
                    completed: false,
                },
                MenuItem {
                    id: 3,
                    title: "Deploy Configuration Files".to_string(),
                    description: "Copy dotfiles to ~/.config".to_string(),
                    completed: false,
                },
                MenuItem {
                    id: 4,
                    title: "Configure WiFi Powersave".to_string(),
                    description: "Disable WiFi power saving".to_string(),
                    completed: false,
                },
                MenuItem {
                    id: 5,
                    title: "Setup Waybar Modules".to_string(),
                    description: "Configure WoL and Tailscale".to_string(),
                    completed: false,
                },
                MenuItem {
                    id: 6,
                    title: "Install Starship Shell".to_string(),
                    description: "Setup starship prompt".to_string(),
                    completed: false,
                },
                MenuItem {
                    id: 7,
                    title: "Install Optional Programs".to_string(),
                    description: "Install notion, vscodium, whatsdesk".to_string(),
                    completed: false,
                },
                MenuItem {
                    id: 0,
                    title: "Exit".to_string(),
                    description: "Quit installer".to_string(),
                    completed: false,
                },
            ],
            selected: 0,
        }
    }

    pub fn next(&mut self) {
        self.selected = (self.selected + 1) % self.items.len();
    }

    pub fn previous(&mut self) {
        if self.selected > 0 {
            self.selected -= 1;
        } else {
            self.selected = self.items.len() - 1;
        }
    }

    pub fn get_selected(&self) -> &MenuItem {
        &self.items[self.selected]
    }
}

pub fn render_menu(frame: &mut Frame, state: &MenuState) {
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(7),  // Header
            Constraint::Min(10),    // Menu items
            Constraint::Length(3),  // Footer
        ])
        .split(frame.area());

    // Header with ASCII art
    let header = Paragraph::new(vec![
        Line::from("╔════════════════════════════════════════════════════╗"),
        Line::from("║     Hyprland Dotfiles Installation Manager        ║"),
        Line::from("║              v1.0.0 - CachyOS Edition              ║"),
        Line::from("╚════════════════════════════════════════════════════╝"),
    ])
    .alignment(Alignment::Center)
    .style(Style::default().fg(Color::Cyan));
    frame.render_widget(header, chunks[0]);

    // Menu items
    let items: Vec<ListItem> = state
        .items
        .iter()
        .enumerate()
        .map(|(idx, item)| {
            let checkbox = if item.completed { "[✓]" } else { "[ ]" };
            let content = format!(" {} {} - {}", checkbox, item.title, item.description);
            
            let style = if idx == state.selected {
                Style::default()
                    .fg(Color::Black)
                    .bg(Color::Cyan)
                    .add_modifier(Modifier::BOLD)
            } else if item.completed {
                Style::default().fg(Color::Green)
            } else {
                Style::default().fg(Color::White)
            };

            ListItem::new(content).style(style)
        })
        .collect();

    let list = List::new(items)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title(" Main Menu ")
                .title_style(Style::default().fg(Color::Yellow))
        );
    frame.render_widget(list, chunks[1]);

    // Footer with controls
    let footer = Paragraph::new(" ↑/↓: Navigate  Enter: Select  q: Quit ")
        .alignment(Alignment::Center)
        .style(Style::default().fg(Color::DarkGray))
        .block(Block::default().borders(Borders::ALL));
    frame.render_widget(footer, chunks[2]);
}
