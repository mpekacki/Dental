public with sharing class DentistHelper {
	
	private ID dentistId;
	
	public DentistHelper(ID dentistId) {
		this.dentistId = dentistId;
	}
	
	public List<AvailableTime__c> getValidHoursForRange(Date validFilterFrom, Date validFilterTo) {
    	
    	List<AvailableTime__c> result = new List<AvailableTime__c>();
    	
    	List<AvailableTime__c> defaultHours = [
            SELECT Date__c, Day_of_week__c, TimeFrom__c, TimeTo__c 
            FROM AvailableTime__c
            WHERE 
                Day_of_week__c != null 
                AND 
                Dentist__c = :this.dentistId 
            ORDER BY 
                Day_of_week__c ASC, 
                TimeFrom__c ASC
        ];
        
    	List<AvailableTime__c> customHours = [
                SELECT Date__c, TimeFrom__c, TimeTo__c 
                FROM AvailableTime__c 
                WHERE 
                    Date__c >= :validFilterFrom 
                    AND 
                    Date__c <= :validFilterTo 
                    AND 
                    Dentist__c = :this.dentistId 
                ORDER BY TimeFrom__c ASC
        ];
        
        for (Date d = validFilterFrom; d <= validFilterTo; d = d.addDays(1)) {
        	List<AvailableTime__c> customHoursForThisDay = ListExtensions.findByDate(customHours, d);
        	if (customHoursForThisDay.size() > 0) {
        		result.addAll(customHoursForThisDay);
        	} else {
        		List<AvailableTime__c> defaultHoursForThisDay = ListExtensions.findByDayOfWeek(defaultHours, getDayOfWeekName(d));
        		if (defaultHoursForThisDay.size() > 0){
        			for (AvailableTime__c def : defaultHoursForThisDay) {
        				AvailableTime__c clne = def.clone(false, false, true, true);
        				clne.Date__c = d;
        				result.add(clne);
        			}
        		} else {
        			AvailableTime__c empty = new AvailableTime__c();
        			empty.Date__c = d;
        			result.add(empty);
        		}
        	}
        }
                
        return result;
    }
    
    public List<HoursPreview> getHoursPreviewByMonthYear(Integer month, Integer year) {
    	List<HoursPreview> preview = new List<HoursPreview>();
    	
    	Date startOfMonth = Date.newInstance(year, month, 1);
    	
    	Date weekStart = startOfMonth.toStartOfWeek();
    	if(weekStart > startOfMonth) {
    		weekStart = weekStart.addDays(-7);
    	}
    	
    	Date endOfMonth = startOfMonth.addMonths(1).addDays(-1);
    	
    	while (weekStart <= endOfMonth) {
    		HoursPreview week = new HoursPreview(weekStart);
    		List<AvailableTime__c> hours = getValidHoursForRange(weekStart, weekStart.addDays(6));
    		
    		for (Integer i = 0; i < hours.size(); i++) {
    			String itemDay = getDayOfWeekName(hours[i].Date__c);
    			boolean isCustom = false;
    			try {
    				String temp = hours[i].Day_of_week__c;
    			} catch (SObjectException e) {
    				isCustom = true;
    			}
				week.writeRanges(itemDay, hours[i].TimeFrom__c, hours[i].TimeTo__c, isCustom);
    		}
    		preview.add(week);
    		
    		weekStart = weekStart.addDays(7);
    	}
    	
    	return preview;
    }
    
    public List<DateTime> extractTimeSlotsStarts(AvailableTime__c a, Integer appointmentLengthInMinutes) {
    	List<DateTime> result = new List<DateTime>();
    	
    	DateTime dtFrom = TimeConverter.extractTimeFrom(a);
    	DateTime dtTo = TimeConverter.extractTimeTo(a);
    	
    	while (dtFrom.addMinutes(appointmentLengthInMinutes) <= dtTo){
    		result.add(dtFrom);
    		dtFrom = dtFrom.addMinutes(appointmentLengthInMinutes);
    	}
    	
    	return result;
    }
    
    public List<AvailableTime__c> carveOutAppointmentsFromTimeBlock(AvailableTime__c a, List<Appointment__c> overlappingApps) {
    	List<AvailableTime__c> result = new List<AvailableTime__c>();
    	
    	for (Integer iApp = 0; iApp < overlappingApps.size(); iApp++) {
    		Appointment__c app = overlappingApps[iApp];
    		Decimal beforeSlotFrom = a.TimeFrom__c;
    		Decimal beforeSlotTo = app.Date_and_time_start__c.hour() * 60 + app.Date_and_time_start__c.minute();
    		
    		Decimal afterSlotFrom = app.Date_and_time_end__c.hour() * 60 + app.Date_and_time_end__c.minute();
    		Decimal afterSlotTo = a.TimeTo__c;
            if (afterSlotFrom == 0) {
                afterSlotFrom = 1440;
            }
    		
    		if(beforeSlotFrom < beforeSlotTo) {
    			AvailableTime__c beforeSlot = a.clone(false, false, false, false);
    			beforeSlot.TimeFrom__c = beforeSlotFrom;
    			beforeSlot.TimeTo__c = beforeSlotTo;
    			result.add(beforeSlot);
    		}
    		
    		if (afterSlotFrom < afterSlotTo) {
    			AvailableTime__c afterSlot = a.clone(false, false, false, false);
    			afterSlot.TimeFrom__c = afterSlotFrom;
    			afterSlot.TimeTo__c = afterSlotTo;
    			if (iApp == overlappingApps.size() - 1) {
    				result.add(afterSlot);
    			}
    			a = afterSlot;
    		}
    	}
    	
    	return result;
    }

    public List<AvailableTime__c> getAvailableHours(Date dateFrom, Date dateTo){
        List<AvailableTime__c> result = new List<AvailableTime__c>();

        List<Appointment__c> appointments = getBlockingAppointments(dateFrom, dateTo);
        List<AvailableTime__c> validHours = getValidHoursForRange(dateFrom, dateTo);
        
        for (AvailableTime__c aTime : validHours) {
            if (aTime.TimeFrom__c == null) {
                continue; // absence, therefore there will be no possible appointment times for this period
            }
            DateTime timeFrom = TimeConverter.extractTimeFrom(aTime);
            DateTime timeTo = TimeConverter.extractTimeTo(aTime);
            List<Appointment__c> overlappingAppointments = ListExtensions.findByTimeFromAndTo(appointments, timeFrom, timeTo);
            if (overlappingAppointments.size() == 0){
                result.add(aTime);
            } else {
                List<AvailableTime__c> fragmentedSlot = carveOutAppointmentsFromTimeBlock(aTime, overlappingAppointments);
                result.addAll(fragmentedSlot);
            }
        }
        
        return result;
    }

    public DentistWithHours getDentistWithHours(Date dateFrom, Date dateTo) {
        DentistWithHours dwh = new DentistWithHours();
        dwh.dentist = [SELECT ID, Name, Speciality__c FROM Dentist__c WHERE ID = :dentistID LIMIT 1];

        List<DateTime> possibleStartTimes = getPossibleAppointmentStartTimes(Constants.APPOINTMENT_TIME_IN_MINUTES, dateFrom, dateTo);

        DayAvailability da;
        for (DateTime dt : possibleStartTimes) {
            if (da == null || dt.date() != da.day) {
                da = new DayAvailability();
                da.day = dt.date();
                dwh.availableDays.add(da);
            }

            DayAvailability.HourRange hr = new DayAvailability.HourRange();
            hr.timeFrom = TimeConverter.formatTime(dt);
            DateTime dtEnd = dt.addMinutes(Constants.APPOINTMENT_TIME_IN_MINUTES);
            hr.timeTo = TimeConverter.formatTime(dtEnd);

            da.availableHours.add(hr);
        }

        return dwh;
    }
    
    public List<DateTime> getPossibleAppointmentStartTimes(Integer appointmentLengthInMinutes, Date dateFrom, Date dateTo) {
    	List<DateTime> result = new List<DateTime>();
    	
    	List<AvailableTime__c> availableHours = getAvailableHours(dateFrom, dateTo);

        for (AvailableTime__c aTime : availableHours) {
            List<DateTime> timeSlotStarts = extractTimeSlotsStarts(aTime, appointmentLengthInMinutes);
            result.addAll(timeSlotStarts);
        }
    	
    	return result;
    }

    public List<DateTime> getPossibleAppointmentStartTimes(Date d){
        return getPossibleAppointmentStartTimes(
            Constants.APPOINTMENT_TIME_IN_MINUTES, 
            d, 
            d.addDays(1));
    }
    
    public List<DateTime> getPossibleAppointmentStartTimes(){
    	return getPossibleAppointmentStartTimes(
    		Constants.APPOINTMENT_TIME_IN_MINUTES, 
    		Date.today().addDays(Constants.EARLIEST_POSSIBLE_APPOINTMENT_DAYS), 
    		Date.today().addDays(Constants.LAST_POSSIBLE_APPOINTMENT_DAYS));
    }
    
    public List<Appointment__c> getBlockingAppointments(Date dateFrom, Date dateTo) {
    	return [
    		SELECT Date_and_time_start__c, Date_and_time_end__c
    		FROM Appointment__c
    		WHERE
    			Dentist__c = :dentistId
    			AND
    			Status__c IN (:Constants.APPOINTMENT_STATUS_AWAITING, :Constants.APPOINTMENT_STATUS_CONFIRMED, :Constants.APPOINTMENT_STATUS_TEMPORARY)
    			AND
    			Date_and_time_start__c >= :((DateTime)dateFrom)
    			AND 
    			Date_and_time_end__c <= :((DateTime)dateTo)
    		ORDER BY Date_and_time_start__c ASC
    	];
    }
    
    public List<AvailableTime__c> getDefaultHours(){        
        return [
            SELECT ID, Day_of_week__c, TimeFrom__c, TimeTo__c 
            FROM AvailableTime__c
            WHERE 
                Day_of_week__c != null 
                AND 
                Dentist__c = :dentistId 
            ORDER BY Day_of_week__c ASC, TimeFrom__c ASC
        ];
    }
    
    public List<AvailableTime__c> getCustomHours(){        
        return [
            SELECT ID, Date__c, TimeFrom__c, TimeTo__c 
            FROM AvailableTime__c
            WHERE 
                Date__c != null 
                AND 
                Dentist__c = :dentistId
            ORDER BY Date__c ASC
        ];
    }
        
    private String getDayOfWeekName(Date d){ 
        return ((DateTime)d).format('EEEE');
    }
}