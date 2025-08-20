#!/bin/bash
yum update -y
yum install -y httpd

systemctl start httpd
systemctl enable httpd

# Create a simple web page
cat <<HTML > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>3-Tier Architecture - ${environment_name}</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container { 
            max-width: 800px; 
            margin: 0 auto; 
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        .tier { 
            background: rgba(255,255,255,0.2); 
            padding: 20px; 
            margin: 20px 0; 
            border-radius: 5px; 
            border-left: 4px solid #fff;
        }
        .presentation { border-left-color: #4CAF50; }
        .application { border-left-color: #2196F3; }
        .data { border-left-color: #FF9800; }
        .info { 
            background: rgba(0,0,0,0.3); 
            padding: 15px; 
            border-radius: 5px; 
            margin: 10px 0;
        }
        h1 { text-align: center; margin-bottom: 30px; }
        h2 { margin-top: 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏗️ 3-Tier Web Architecture</h1>
        
        <div class="tier presentation">
            <h2>🌐 Presentation Tier</h2>
            <p>Application Load Balancer + Public Subnets</p>
            <div class="info">
                <strong>Load Balancer:</strong> Distributes traffic across multiple instances
            </div>
        </div>
        
        <div class="tier application">
            <h2>⚙️ Application Tier</h2>
            <p>EC2 Instances + Auto Scaling Group + Private Subnets</p>
            <div class="info">
                <strong>Region:</strong> ${aws_region}<br>
                <strong>Environment:</strong> ${environment_name}<br>
                <strong>Instance ID:</strong> <span id="instance-id">Loading...</span><br>
                <strong>Availability Zone:</strong> <span id="az">Loading...</span>
            </div>
        </div>
        
        <div class="tier data">
            <h2>🗄️ Data Tier</h2>
            <p>RDS MySQL + Database Subnets</p>
            <div class="info">
                <strong>Database:</strong> Isolated in private subnets with encryption
            </div>
        </div>
        
        <div style="text-align: center; margin-top: 30px; opacity: 0.8;">
            <p>Deployed with Terraform Modules</p>
            <p>Last updated: $(date)</p>
        </div>
    </div>

    <script>
        // Fetch instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data)
            .catch(() => document.getElementById('instance-id').textContent = 'N/A');
            
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => document.getElementById('az').textContent = data)
            .catch(() => document.getElementById('az').textContent = 'N/A');
    </script>
</body>
</html>
HTML
