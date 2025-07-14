<?php
// Add these functions to your existing api.php file

function getStudentInboxPending($conn) {
    $input = json_decode(file_get_contents('php://input'), true);
    $userID = $input['userID'];
    
    try {
        // Get pending and accepted appointments (upcoming appointments)
        $sql = "SELECT 
                    a.appointment_id,
                    a.teacher_id,
                    a.status,
                    a.created_at,
                    u.user_fn as teacher_fn,
                    u.user_ln as teacher_ln,
                    CONCAT(u.user_fn, ' ', u.user_ln) as teacher_full_name,
                    COALESCE(ud.department, 'No Department Assigned') as department,
                    s.day_of_week,
                    s.start_time,
                    s.end_time
                FROM appointments a
                JOIN users u ON a.teacher_id = u.user_id
                LEFT JOIN user_dept ud ON u.user_id = ud.user_id
                JOIN schedules s ON a.schedule_id = s.schedule_id
                WHERE a.student_id = ? 
                AND a.status IN ('pending', 'accepted')
                ORDER BY a.created_at DESC
                LIMIT 20";
        
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
                    'teacher_full_name' => $row['teacher_full_name'],
                    'department' => $row['department'],
                    'status' => $row['status'],
                    'created_at' => $row['created_at'],
                    'day_of_week' => $row['day_of_week'],
                    'start_time' => $row['start_time'],
                    'end_time' => $row['end_time']
                ];
            }
            
            echo json_encode([
                'success' => true,
                'error' => false,
                'message' => 'Pending appointments retrieved successfully!',
                'count' => count($appointments),
                'appointments' => $appointments
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'error' => true,
                'message' => 'No pending appointments found',
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

function getStudentInboxCompleted($conn) {
    $input = json_decode(file_get_contents('php://input'), true);
    $userID = $input['userID'];
    
    try {
        // Get completed appointments
        $sql = "SELECT 
                    a.appointment_id,
                    a.teacher_id,
                    a.status,
                    a.created_at,
                    u.user_fn as teacher_fn,
                    u.user_ln as teacher_ln,
                    CONCAT(u.user_fn, ' ', u.user_ln) as teacher_full_name,
                    COALESCE(ud.department, 'No Department Assigned') as department,
                    s.day_of_week,
                    s.start_time,
                    s.end_time
                FROM appointments a
                JOIN users u ON a.teacher_id = u.user_id
                LEFT JOIN user_dept ud ON u.user_id = ud.user_id
                JOIN schedules s ON a.schedule_id = s.schedule_id
                WHERE a.student_id = ? 
                AND a.status = 'completed'
                ORDER BY a.created_at DESC
                LIMIT 20";
        
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
                    'teacher_full_name' => $row['teacher_full_name'],
                    'department' => $row['department'],
                    'status' => $row['status'],
                    'created_at' => $row['created_at'],
                    'day_of_week' => $row['day_of_week'],
                    'start_time' => $row['start_time'],
                    'end_time' => $row['end_time']
                ];
            }
            
            echo json_encode([
                'success' => true,
                'error' => false,
                'message' => 'Completed appointments retrieved successfully!',
                'count' => count($appointments),
                'appointments' => $appointments
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'error' => true,
                'message' => 'No completed appointments found',
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

function getStudentInboxMissed($conn) {
    $input = json_decode(file_get_contents('php://input'), true);
    $userID = $input['userID'];
    
    try {
        // Get missed appointments
        $sql = "SELECT 
                    a.appointment_id,
                    a.teacher_id,
                    a.status,
                    a.created_at,
                    u.user_fn as teacher_fn,
                    u.user_ln as teacher_ln,
                    CONCAT(u.user_fn, ' ', u.user_ln) as teacher_full_name,
                    COALESCE(ud.department, 'No Department Assigned') as department,
                    s.day_of_week,
                    s.start_time,
                    s.end_time
                FROM appointments a
                JOIN users u ON a.teacher_id = u.user_id
                LEFT JOIN user_dept ud ON u.user_id = ud.user_id
                JOIN schedules s ON a.schedule_id = s.schedule_id
                WHERE a.student_id = ? 
                AND a.status = 'missed'
                ORDER BY a.created_at DESC
                LIMIT 20";
        
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
                    'teacher_full_name' => $row['teacher_full_name'],
                    'department' => $row['department'],
                    'status' => $row['status'],
                    'created_at' => $row['created_at'],
                    'day_of_week' => $row['day_of_week'],
                    'start_time' => $row['start_time'],
                    'end_time' => $row['end_time']
                ];
            }
            
            echo json_encode([
                'success' => true,
                'error' => false,
                'message' => 'Missed appointments retrieved successfully!',
                'count' => count($appointments),
                'appointments' => $appointments
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'error' => true,
                'message' => 'No missed appointments found',
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

function getStudentInboxCancelled($conn) {
    $input = json_decode(file_get_contents('php://input'), true);
    $userID = $input['userID'];
    
    try {
        // Get declined (cancelled) appointments
        $sql = "SELECT 
                    a.appointment_id,
                    a.teacher_id,
                    a.status,
                    a.created_at,
                    u.user_fn as teacher_fn,
                    u.user_ln as teacher_ln,
                    CONCAT(u.user_fn, ' ', u.user_ln) as teacher_full_name,
                    COALESCE(ud.department, 'No Department Assigned') as department,
                    s.day_of_week,
                    s.start_time,
                    s.end_time
                FROM appointments a
                JOIN users u ON a.teacher_id = u.user_id
                LEFT JOIN user_dept ud ON u.user_id = ud.user_id
                JOIN schedules s ON a.schedule_id = s.schedule_id
                WHERE a.student_id = ? 
                AND a.status = 'declined'
                ORDER BY a.created_at DESC
                LIMIT 20";
        
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
                    'teacher_full_name' => $row['teacher_full_name'],
                    'department' => $row['department'],
                    'status' => $row['status'],
                    'created_at' => $row['created_at'],
                    'day_of_week' => $row['day_of_week'],
                    'start_time' => $row['start_time'],
                    'end_time' => $row['end_time']
                ];
            }
            
            echo json_encode([
                'success' => true,
                'error' => false,
                'message' => 'Cancelled appointments retrieved successfully!',
                'count' => count($appointments),
                'appointments' => $appointments
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'error' => true,
                'message' => 'No cancelled appointments found',
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

// ADD THESE CASES TO YOUR EXISTING SWITCH STATEMENT IN api.php:

/*
case 'getStudentInboxPending':
    getStudentInboxPending($conn);
    break;
    
case 'getStudentInboxCompleted':
    getStudentInboxCompleted($conn);
    break;
    
case 'getStudentInboxMissed':
    getStudentInboxMissed($conn);
    break;
    
case 'getStudentInboxCancelled':
    getStudentInboxCancelled($conn);
    break;
*/
?>
