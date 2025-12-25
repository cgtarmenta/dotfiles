mod models;
mod ui;
mod utils;

use crossterm::{
    event::{self, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    Terminal,
};
use std::io;
use ui::{MenuState, render_menu};
use utils::{check_yay, run_script_function};

fn main() -> anyhow::Result<()> {
    // Check for yay
    if !check_yay() {
        eprintln!("Error: yay is not installed. Please install yay first.");
        eprintln!("Visit: https://github.com/Jguer/yay");
        std::process::exit(1);
    }

    // Setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Create menu state
    let mut menu_state = MenuState::new();
    let mut should_quit = false;

    // Main event loop
    while !should_quit {
        terminal.draw(|f| render_menu(f, &menu_state))?;

        if let Event::Key(key) = event::read()? {
            if key.kind == KeyEventKind::Press {
                match key.code {
                    KeyCode::Char('q') | KeyCode::Esc => {
                        should_quit = true;
                    }
                    KeyCode::Down | KeyCode::Char('j') => {
                        menu_state.next();
                    }
                    KeyCode::Up | KeyCode::Char('k') => {
                        menu_state.previous();
                    }
                    KeyCode::Enter => {
                        let selected = menu_state.get_selected();
                        if selected.id == 0 {
                            should_quit = true;
                        } else {
                            // Exit TUI temporarily to run command
                            disable_raw_mode()?;
                            execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
                            
                            // Run the installation step
                            let result = execute_menu_action(selected.id);
                            
                            // Wait for user confirmation before re-entering TUI
                            println!("\nPress Enter to continue...");
                            let mut input = String::new();
                            let _ = io::stdin().read_line(&mut input);
                            
                            // Re-enter TUI
                            enable_raw_mode()?;
                            execute!(terminal.backend_mut(), EnterAlternateScreen)?;
                            
                            if result.is_ok() {
                                menu_state.items[menu_state.selected].completed = true;
                            } else if let Err(e) = result {
                                eprintln!("Error: {}", e);
                            }
                        }
                    }
                    _ => {}
                }
            }
        }
    }

    // Restore terminal
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    terminal.show_cursor()?;

    Ok(())
}

fn execute_menu_action(id: usize) -> anyhow::Result<()> {
    println!("\n╔═══════════════════════════════════════════════════╗");
    println!("║          Executing Installation Step              ║");
    println!("╚═══════════════════════════════════════════════════╝\n");

    match id {
        1 => {
            println!("Running full installation...\n");
            run_script_function("full_installation")?;
        }
        2 => {
            println!("Installing core packages...\n");
            run_script_function("install_packages")?;
        }
        3 => {
            println!("Deploying configuration files...\n");
            run_script_function("deploy_configs")?;
        }
        4 => {
            println!("Configuring WiFi powersave...\n");
            run_script_function("configure_wifi")?;
        }
        5 => {
            println!("Setting up Waybar modules...\n");
            run_script_function("setup_waybar_modules")?;
        }
        6 => {
            println!("Installing Starship shell...\n");
            run_script_function("install_starship")?;
        }
        7 => {
            println!("Installing optional programs...\n");
            run_script_function("install_optional")?;
        }
        _ => {}
    }

    println!("\n╔═══════════════════════════════════════════════════╗");
    println!("║              Step Completed!                      ║");
    println!("╚═══════════════════════════════════════════════════╝\n");

    Ok(())
}
