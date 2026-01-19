
import { useState } from 'react';
import { createPortal } from 'react-dom';
import Icon from '../Icon';

interface ShareModalProps {
    isOpen: boolean;
    onClose: () => void;
    url: string;
    title: string;
    description?: string;
    image?: string;
}

const ShareModal = ({ isOpen, onClose, url, title, description, image }: ShareModalProps) => {
    const [copied, setCopied] = useState(false);

    // Reset copied state when opening
    if (isOpen && copied) {
        setCopied(false);
    }

    if (!isOpen) return null;

    const handleCopy = async () => {
        try {
            await navigator.clipboard.writeText(url);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        } catch (err) {
            console.error('Failed to copy', err);
        }
    };

    const modalContent = (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-[100] flex items-center justify-center p-4 animate-fade-in">
            <div className="bg-panel w-full max-w-lg border border-border rounded-lg shadow-2xl flex flex-col scale-100 animate-slide-up">
                {/* Header */}
                <div className="p-4 border-b border-border flex justify-between items-center bg-surface rounded-t-lg">
                    <div className="flex items-center gap-2 text-white">
                        <Icon name="share" className="text-primary" />
                        <h3 className="font-bold text-lg font-mono">Share {title}</h3>
                    </div>
                    <button
                        className="text-text-muted hover:text-white"
                        onClick={onClose}
                    >
                        <Icon name="close" />
                    </button>
                </div>

                {/* Body */}
                <div className="p-6">
                    <p className="text-sm text-text-muted mb-4">
                        Copy the link below to share this page with others.
                    </p>

                    {/* Social Preview Card */}
                    <div className="mb-6 rounded-xl border border-border overflow-hidden bg-black/40">
                        {image && (
                            <div className="aspect-[1.91/1] w-full overflow-hidden bg-surface-muted relative">
                                <img
                                    src={image}
                                    alt="Preview"
                                    className="w-full h-full object-cover"
                                    onError={(e) => {
                                        // Fallback if image fails or is relative/invalid
                                        e.currentTarget.style.display = 'none';
                                    }}
                                />
                            </div>
                        )}
                        <div className="p-3">
                            <div className="text-xs text-text-muted uppercase font-mono mb-1 truncate">
                                {new URL(url).hostname}
                            </div>
                            <div className="font-bold text-white text-sm mb-1 line-clamp-1">
                                {title}
                            </div>
                            {description && (
                                <div className="text-xs text-text-muted line-clamp-2">
                                    {description}
                                </div>
                            )}
                        </div>
                    </div>

                    <div className="bg-background border border-border rounded p-1 flex items-center gap-2">
                        <div className="flex-1 px-2 py-2 overflow-x-auto whitespace-nowrap scrollbar-hide">
                            <span className="text-sm text-white font-mono">{url}</span>
                        </div>
                        <button
                            onClick={handleCopy}
                            className={`px-4 py-2 rounded text-xs font-bold uppercase transition-all flex items-center gap-2 ${copied
                                ? 'bg-green-500 text-white'
                                : 'bg-primary text-black hover:bg-white'
                                }`}
                        >
                            {copied ? (
                                <>
                                    <Icon name="check" className="text-sm" />
                                    Copied
                                </>
                            ) : (
                                <>
                                    <Icon name="content_copy" className="text-sm" />
                                    Copy
                                </>
                            )}
                        </button>
                    </div>

                    {/* Social Icons Placeholder (Optional visual enhancement) */}
                    <div className="mt-6 flex flex-col gap-2">
                        <span className="text-[10px] text-text-muted uppercase font-bold">Or share via</span>
                        <div className="flex gap-4">
                            <a href={`https://twitter.com/intent/tweet?url=${encodeURIComponent(url)}&text=${encodeURIComponent(title)}`} target="_blank" rel="noopener noreferrer" className="p-3 bg-white/5 rounded hover:bg-white/10 text-white transition-colors">
                                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"></path></svg>
                            </a>
                            <a href={`https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(url)}`} target="_blank" rel="noopener noreferrer" className="p-3 bg-white/5 rounded hover:bg-white/10 text-white transition-colors">
                                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path fillRule="evenodd" d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z" clipRule="evenodd"></path></svg>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );

    // Render modal in a portal at document.body level to avoid z-index issues
    return createPortal(modalContent, document.body);
};

export default ShareModal;
