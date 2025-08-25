# focus_aggressively.py
import win32gui
import win32process
import win32con
import win32com.client
import sys
import time

def focus_window_aggressively(title):
    try:
        print(f"Python: Procurando janela com título: '{title}'")
        hwnd = win32gui.FindWindow(None, title)
        
        if hwnd == 0:
            print("Python: Erro - Janela não encontrada.")
            return

        print(f"Python: Janela encontrada (Handle: {hwnd}). Aplicando técnicas de foco...")

        # Técnica 1: O truque da tecla ALT para destravar o foco
        try:
            shell = win32com.client.Dispatch("WScript.Shell")
            shell.SendKeys('%')
            time.sleep(0.2)
        except Exception as e:
            print(f"Python: Falha ao enviar a tecla ALT (WScript.Shell pode não estar disponível): {e}")

        # Técnica 2: AttachThreadInput para se "apresentar" ao Windows
        fg_window_hwnd = win32gui.GetForegroundWindow()
        fg_thread_id, _ = win32process.GetWindowThreadProcessId(fg_window_hwnd)
        current_thread_id, _ = win32process.GetWindowThreadProcessId(hwnd)


        try:
            # Anexa a thread do jogo à thread em primeiro plano
            win32process.AttachThreadInput(current_thread_id, fg_thread_id, True)
            
            # Técnica 3: Múltiplos comandos para trazer a janela para frente
            win32gui.BringWindowToTop(hwnd)
            win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE) # Maximiza se não estiver
            win32gui.SetForegroundWindow(hwnd)
        finally:
            # Garante que a desconexão sempre ocorra para evitar bugs
            win32process.AttachThreadInput(current_thread_id, fg_thread_id, False)

        print("Python: Comandos de foco agressivo enviados.")

    except Exception as e:
        print(f"Python: Um erro inesperado ocorreu: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        window_title = " ".join(sys.argv[1:])
        focus_window_aggressively(window_title)
    else:
        print("Python: Erro - Nenhum título de janela foi fornecido.")
