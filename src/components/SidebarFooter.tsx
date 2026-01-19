const SidebarFooter = () => {
    return (
        <div className="p-6 border-t border-border bg-background">
            <div className="text-[9px] text-text-muted mono">LOGGED_AS: Anonymous_Analyst</div>
            <div className="flex items-center gap-2 text-[9px] text-primary mono animate-pulse mt-1">
                <span className="w-1.5 h-1.5 rounded-full bg-primary"></span> ENCRYPTED_CONNECTION
            </div>
        </div>
    );
};

export default SidebarFooter;
