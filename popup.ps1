Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Contenu ---
$title  = "Fin du support Windows 10  Préparez dès maintenant votre migration"
$line1  = "Microsoft arrêtera définitivement le support de Windows 10 le 14 octobre 2025."
$sub    = "Concrètement, cela signifie :"
$bullets = @(
  "• Arrêt des mises à jour de sécurité",
  "• Risque accru de cyberattaques et de perte de données",
  "• Compatibilité limitée à terme avec vos logiciels métiers"
) -join "`r`n"
$final  = "Pour continuer à travailler en toute sécurité et garantir la pérennité de vos applications," + `
          "`r`n" + "ne prenez pas de risque et contactez nous dès aujourd’hui au 03 44 06 40 01" + `
          "`r`n" + "pour passer à un PC sous Windows 11, sécurisé et optimisé."

# --- Fenêtre ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Information"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
$form.StartPosition = "Manual"
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi

# Largeur fixe, hauteur calculée après mise en page
$margin = 12
$formWidth = 500
$form.ClientSize = [System.Drawing.Size]::new($formWidth, 200)  # hauteur provisoire
$maxLabelWidth = $form.ClientSize.Width - 2*$margin

$fontTitle = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)
$fontText  = New-Object System.Drawing.Font("Segoe UI",10)
$fontUnder = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Underline)

function New-WrappedLabel([string]$text, [System.Drawing.Font]$font, [int]$left, [int]$top, [int]$maxWidth) {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $text
    $lbl.Font = $font
    $lbl.AutoSize = $true
    $lbl.MaximumSize = [System.Drawing.Size]::new($maxWidth, 0)  # wrap dynamique
    $lbl.Location = [System.Drawing.Point]::new($left, $top)
    return $lbl
}

# Mise en page verticale (calcul auto des hauteurs)
$y = $margin
$lblTitle = New-WrappedLabel $title  $fontTitle $margin $y $maxLabelWidth; $form.Controls.Add($lblTitle); $y = $lblTitle.Bottom + 4
$lblL1    = New-WrappedLabel $line1  $fontText  $margin $y $maxLabelWidth; $form.Controls.Add($lblL1);    $y = $lblL1.Bottom + 6
$lblSub   = New-WrappedLabel $sub    $fontUnder $margin $y $maxLabelWidth; $form.Controls.Add($lblSub);   $y = $lblSub.Bottom + 4
$lblBul   = New-WrappedLabel $bullets $fontText ($margin+10) $y ($maxLabelWidth-10); $form.Controls.Add($lblBul); $y = $lblBul.Bottom + 6
$lblFin   = New-WrappedLabel $final  $fontText  $margin $y $maxLabelWidth; $form.Controls.Add($lblFin);   $y = $lblFin.Bottom + $margin

# Ajuste la hauteur de la fenêtre à son contenu
$form.ClientSize = [System.Drawing.Size]::new($formWidth, $y)

# Position bas-droite (en respectant la barre des tâches)
$wa = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$form.Left = $wa.Right  - $form.Width  - $margin
$form.Top  = $wa.Bottom - $form.Height - $margin

# Timer d'auto-fermeture (15 s)
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 25000
$timer.Add_Tick({ $timer.Stop(); $form.Close() })
$timer.Start()

[void]$form.ShowDialog()
