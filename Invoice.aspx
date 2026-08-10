<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <title>Invoice</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #fff;
            color: #000;
            padding: 20px;
        }
        
        .top {
            text-align: center;
            line-height: 1.5;
            margin-top: 10px;
            font-size: 14px;
        }
        
        table {
            border-collapse: collapse;
            width: 95%;
            margin: 20px auto;
            font-size: 13px;
        }
        
        td, th {
            border: 1px solid #000;
            padding: 6px;
            text-align: center;
        }
        
        th {
            background-color: #f2f2f2;
            font-weight: bold;
        }
        
        .bold {
            font-weight: bold;
        }
        
        .left {
            text-align: left;
        }
        
        .right {
            text-align: right;
        }
        
        .no-print-btn {
            margin: 10px;
            padding: 8px 16px;
            background-color: #4f46e5;
            color: white;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
        }
        .no-print-btn:hover {
            background-color: #3730a3;
        }

        @media print {
            @page {
                margin: 0;
            }
            body {
                margin: 1.5cm;
                padding: 0;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
            table {
                width: 100% !important;
                margin: 20px 0 !important;
            }
            .no-print {
                display: none !important;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="no-print" style="text-align: left; margin-bottom: 20px;">
            <button type="button" class="no-print-btn" onclick="window.print()">
                <i class="fas fa-print"></i> Print Invoice
            </button>
            <button type="button" class="no-print-btn" style="background-color: #6b7280;" onclick="window.close()">
                Close Window
            </button>
        </div>

        <div class="top">
            <b>Contract No.511687761569464 Dt. 17 Oct 2025</b><br>
            Manpower Outstanding Services - Data Entry Operators (<span id="cat"></span>) - <span id="count"></span> Nos.<br>
            Contract Period 24 Oct 2025 to 23 Oct 2027 - 26 days<br>
            M/s Vishal Manpower and Security Consultants, Mangalore<br>
            Payment for the period <span id="period"></span>
        </div>

        <table id="tbl"></table>

        <script>
            // ===== DATE FORMAT =====
            function getPeriod(year, month) {
                const start = new Date(year, month, 1);
                const end = new Date(year, month + 1, 0);
                const opt = { day: '2-digit', month: 'short', year: 'numeric' };
                return `${start.toLocaleDateString('en-GB', opt)} to ${end.toLocaleDateString('en-GB', opt)}`;
            }

            // ===== LOAD DATA =====
            function load() {
                const data = JSON.parse(localStorage.getItem("finalData") || "{}");
                const RATE = Number(data.rate) || 0;
                const emps = data.employees || [];
                const category = data.category || "Skilled";
                const year = data.year || new Date().getFullYear();
                const month = data.month || new Date().getMonth();

                document.getElementById("cat").innerText = category;
                document.getElementById("count").innerText = emps.length;
                document.getElementById("period").innerText = getPeriod(year, month);

                // ===== GROUP BY RATE AND DAYS =====
                let group = {};
                let totalDays = 0;
                let base = 0;

                emps.forEach(e => {
                    const d = e.days || 0;
                    const empRate = Number(e.rate) || RATE;
                    const key = `${empRate}_${d}`;
                    if (!group[key]) {
                        group[key] = {
                            rate: empRate,
                            days: d,
                            count: 0
                        };
                    }
                    group[key].count++;
                    totalDays += d;
                    base += d * empRate;
                });

                let rows = "";
                let i = 1;

                Object.keys(group).sort((a, b) => {
                    const [rateA, daysA] = a.split('_').map(Number);
                    const [rateB, daysB] = b.split('_').map(Number);
                    if (rateB !== rateA) return rateB - rateA;
                    return daysB - daysA;
                }).forEach(key => {
                    const item = group[key];
                    const total = item.count * item.days * item.rate;
                    rows += `
                    <tr>
                        <td>${i++}</td>
                        <td class="left">Data Entry Operators (${category})</td>
                        <td>${item.rate.toFixed(2)}</td>
                        <td>${item.count}</td>
                        <td>${item.days}</td>
                        <td>${total.toFixed(2)}</td>
                    </tr>`;
                });

                // ===== PF CALC =====
                let pfHigh = 0, pfLow = 0, high = 0, low = 0;

                emps.forEach(e => {
                    const empRate = Number(e.rate) || RATE;
                    const wage = e.days * empRate;
                    if (wage > 15000) {
                        pfHigh += 1800; // max cap
                        high++;
                    } else {
                        pfLow += wage * 0.13;
                        low++;
                    }
                });

                const pf = pfHigh + pfLow;
                const sub = base + pf;
                const service = sub * 0.0385;
                const gst = (sub + service) * 0.18;
                const total = sub + service + gst;

                // ===== TABLE =====
                document.getElementById("tbl").innerHTML = `
                <tr>
                    <th>Sl No</th>
                    <th>Description</th>
                    <th>Payment per person / month (Rs/-PD)</th>
                    <th>No of people</th>
                    <th>No of Days/Individual</th>
                    <th>Total No. of working days (Rs)</th>
                </tr>

                ${rows}

                <tr>
                    <td colspan="3" class="bold">Total No of People</td>
                    <td class="bold">${emps.length}</td>
                    <td class="bold">Total No of Days</td>
                    <td class="bold">${totalDays}</td>
                </tr>



                <tr>
                    <td colspan="5" class="left">EPF @ 13% for ${high} persons (Above Rs. 15,000/- capped at Rs. 1,800/-)</td>
                    <td>${pfHigh.toFixed(2)}</td>
                </tr>

                <tr>
                    <td colspan="5" class="left">EPF @ 13% for ${low} persons (Under Rs. 15,000/- at 13% rate)</td>
                    <td>${pfLow.toFixed(2)}</td>
                </tr>

                <tr>
                    <td colspan="5" class="left bold">Sub Total</td>
                    <td class="bold">${sub.toFixed(2)}</td>
                </tr>

                <tr>
                    <td colspan="5" class="left">Service Charge @ 3.85%</td>
                    <td>${service.toFixed(2)}</td>
                </tr>

                <tr>
                    <td colspan="5" class="left">GST @ 18%</td>
                    <td>${gst.toFixed(2)}</td>
                </tr>

                <tr>
                    <td colspan="5" class="left bold">Total Cost Per Month</td>
                    <td class="bold">${total.toFixed(2)}</td>
                </tr>
                `;
            }

            load();
        </script>
    </form>
</body>
</html>
