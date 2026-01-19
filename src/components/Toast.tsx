import { useEffect } from "react";
import Icon from "./Icon";

type ToastType = "success" | "error" | "warning" | "info";

type ToastProps = {
    message: string;
    type?: ToastType;
    onClose: () => void;
    duration?: number;
};

const Toast = ({ message, type = "success", onClose, duration = 3000 }: ToastProps) => {
    useEffect(() => {
        const timer = setTimeout(() => {
            onClose();
        }, duration);

        return () => clearTimeout(timer);
    }, [duration, onClose]);

    const styles = {
        success: {
            bg: 'bg-primary/20',
            border: 'border-primary',
            text: 'text-primary',
            icon: 'check_circle'
        },
        error: {
            bg: 'bg-red-500/20',
            border: 'border-red-500',
            text: 'text-red-500',
            icon: 'error'
        },
        warning: {
            bg: 'bg-amber-500/20',
            border: 'border-amber-500',
            text: 'text-amber-500',
            icon: 'warning'
        },
        info: {
            bg: 'bg-blue-500/20',
            border: 'border-blue-500',
            text: 'text-blue-500',
            icon: 'info'
        }
    };

    const style = styles[type] || styles.success;

    return (
        <div className="fixed bottom-6 right-6 z-[100] animate-slide-up">
            <div className={`${style.bg} border ${style.border} ${style.text} px-4 py-3 rounded-lg shadow-2xl flex items-center gap-3 min-w-[300px] max-w-md backdrop-blur-sm`}>
                <Icon name={style.icon} className="text-xl" />
                <span className="flex-1 text-sm font-medium">{message}</span>
                <button
                    onClick={onClose}
                    className="text-text-muted hover:text-white transition-colors"
                >
                    <Icon name="close" className="text-sm" />
                </button>
            </div>
        </div>
    );
};

export default Toast;
