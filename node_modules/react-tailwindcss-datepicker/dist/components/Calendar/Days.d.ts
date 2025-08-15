interface Props {
    days: {
        previous: Date[];
        current: Date[];
        next: Date[];
    };
    onClickPreviousDays: (day: Date) => void;
    onClickDay: (day: Date) => void;
    onClickNextDays: (day: Date) => void;
}
declare const Days: (props: Props) => import("react/jsx-runtime").JSX.Element;
export default Days;
