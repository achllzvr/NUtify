<?php
// Updated functions for Student Home page - add these to your api.php

function getRecentProfessors($conn) {
    $input = json_decode(file_get_contents('php://input'), true);
    $userID = $input['userID'] ?? null;
    
    if (!$userID) {
        echo json_encode([
            'success' => false,
            'error' => true,
            'message' => 'Missing userID parameter',
            'professors' => []
        ]);
        return;
    }
    
    try {
        // Get recent professors from completed appointments, ordered by most recent
        $sql = "SELECT DISTINCT
                    u.user_id as teacher_id,
                    u.user_fn as teacher_fn,
                    u.user_ln as teacher_ln,
                    COALESCE(ud.department, 'No Department Assigned') as department,
                    MAX(a.created_at) as last_appointment
                FROM appointments a
                JOIN users u ON a.teacher_id = u.user_id
                LEFT JOIN user_dept ud ON u.user_id = ud.user_id
                WHERE a.student_id = ? 
                AND a.status IN ('completed', 'accepted', 'pending')
                GROUP BY u.user_id, u.user_fn, u.user_ln, ud.department
                ORDER BY last_appointment DESC
                LIMIT 5";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $userID);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $professors = [];
            while ($row = $result->fetch_assoc()) {
                $professors[] = [
                    'teacher_id' => $row['teacher_id'],
                    'teacher_fn' => $row['teacher_fn'],
                    'teacher_ln' => $row['teacher_ln'],
                    'department' => $row['department'],
                    'last_appointment' => $row['last_appointment']
                ];
            }
            
            echo json_encode([
                'success' => true,
                'error' => false,
                'message' => 'Recent professors retrieved successfully!',
                'count' => count($professors),
                'professors' => $professors
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'error' => true,
                'message' => 'No recent professors found',
                'count' => 0,
                'professors' => []
            ]);
        }
        
        $stmt->close();
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'error' => true,
            'message' => 'Database error: ' . $e->getMessage(),
            'count' => 0,
            'professors' => []
        ]);
    }
}

function getStudentHomeAppointments($conn) {
    $input = json_decode(file_get_contents('php://input'), true);
    $userID = $input['userID'] ?? null;
    
    if (!$userID) {
        echo json_encode([
            'success' => false,
            'error' => true,
            'message' => 'Missing userID parameter',
            'appointments' => []
        ]);
        return;
    }
    
    try {
        // Get upcoming appointments (ONLY accepted status for Student Home)
        $sql = "SELECT 
                    a.appointment_id,
                    a.teacher_id,
                    a.status,
                    a.created_at,
                    u.user_fn as teacher_fn,
                    u.user_ln as teacher_ln,
                    COALESCE(ud.department, 'No Department Assigned') as department,
                    s.day_of_week as schedule_date,
                    CONCAT(s.start_time, ' - ', s.end_time) as schedule_time,
                    s.start_time,
                    s.end_time
                FROM appointments a
                JOIN users u ON a.teacher_id = u.user_id
                LEFT JOIN user_dept ud ON u.user_id = ud.user_id
                JOIN schedules s ON a.schedule_id = s.schedule_id
                WHERE a.student_id = ? 
                AND a.status = 'accepted'
                ORDER BY a.created_at DESC
                LIMIT 10";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $userID);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $appointments = [];
            while ($row = $result->fetch_assoc()) {
                $appointments[] = [
                    'appointment_id' => $row['appointment_id'],
                    'teacher_id' => $row['teacher_id'],
                    'teacher_fn' => $row['teacher_fn'],
                    'teacher_ln' => $row['teacher_ln'],
                    'department' => $row['department'],
                    'status' => $row['status'],
                    'created_at' => $row['created_at'],
                    'schedule_date' => $row['schedule_date'],
                    'schedule_time' => $row['schedule_time'],
                    'start_time' => $row['start_time'],
                    'end_time' => $row['end_time']
                ];
            }
            
            echo json_encode([
                'success' => true,
                'error' => false,
                'message' => 'Upcoming appointments retrieved successfully!',
                'count' => count($appointments),
                'appointments' => $appointments
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'error' => true,
                'message' => 'No upcoming appointments found',
                'count' => 0,
                'appointments' => []
            ]);
        }
        
        $stmt->close();
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'error' => true,
            'message' => 'Database error: ' . $e->getMessage(),
            'count' => 0,
            'appointments' => []
        ]);
    }
}

// Make sure these cases exist in your switch statement:
/*
case 'getRecentProfessors':
    getRecentProfessors($conn);
    break;
    
case 'getStudentHomeAppointments':
    getStudentHomeAppointments($conn);
    break;
*/
?>
